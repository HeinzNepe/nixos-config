{ config, pkgs, lib, ... }:

# News Digest NixOS Module
# This module provides all the services needed for the News Digest service

let
  # Module arguments with defaults
  cfg = config.services.news;
  
  # Default repository path
  repoPath = "/opt/news";
  
  # Data directories
  dataDir = "/var/lib/news";
  rawDir = "${dataDir}/raw";
  digestsDir = "${dataDir}/digests";
  staticDir = "${dataDir}/static";
  stateDir = "${dataDir}/state";
  runDir = "${dataDir}/run";
  pendingDir = "${dataDir}/pending";
  
  # User and group
  newsUser = "news";
  newsGroup = "news";
  
  # Python path - use system python3
  python = pkgs.python3;
  
  # Path to the runner script
  runnerScript = "${repoPath}/run-digest.py";
  
  # Path to the API server (to be created)
  apiScript = "${repoPath}/api/server.py";
  
  # Path to the news.env file
  envFile = "/etc/news/news.env";

in

{
  options.services.news = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the News Digest service";
    };
    
    # Service configuration
    schedule = lib.mkOption {
      type = lib.types.str;
      default = "06:30";
      description = "Daily run time (HH:MM) in Europe/Oslo timezone";
    };
    selfUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://news.nepstad.it";
      description = "Base URL for the news digest site";
    };
    apiPort = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "Port for the external AI webhook API";
    };
    externalAiTimeoutMinutes = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Timeout in minutes for external AI";
    };
    externalAiApiKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Optional API key for external AI authentication";
    };
    keepRawDays = lib.mkOption {
      type = lib.types.int;
      default = 7;
      description = "Number of days to keep raw feed data";
    };
    keepArchivesYears = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Number of years to keep digest archives";
    };
    
    # Repository path (where the code is installed)
    repoPath = lib.mkOption {
      type = lib.types.path;
      default = "/opt/news";
      description = "Path to the news digest repository";
    };
    
    # Web root for static files (where viewer.html and JSON digests are served from)
    webrootPath = lib.mkOption {
      type = lib.types.path;
      default = "${config.services.news.repoPath}/webroot";
      description = "Path to web root directory for static files";
    };
    
    # Git configuration for archival
    gitRemote = lib.mkOption {
      type = lib.types.str;
      default = "origin";
      description = "Git remote name for archival push";
    };
    gitEmail = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Git commit email for archival";
    };
    gitName = lib.mkOption {
      type = lib.types.str;
      default = "News Digest";
      description = "Git commit name for archival";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create the news user and group
    users.users.${newsUser} = {
      isSystemUser = true;
      group = newsGroup;
      home = dataDir;
      shell = pkgs.bash;
    };
    
    users.groups.${newsGroup} = { };
    
    # Create data directories
    
    # Ensure repository directory exists
    # Use lib.mkForce to override any existing tmpfiles rules
    systemd.tmpfiles.rules = lib.mkForce [
      "d /etc/news 0755 root root - -"
      "d ${dataDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${rawDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${digestsDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${staticDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${stateDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${runDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${pendingDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${dataDir}/source-probe 0755 ${newsUser} ${newsGroup} - -"
      "d ${dataDir}/log 0755 ${newsUser} ${newsGroup} - -"
      "d ${cfg.repoPath} 0755 root root - -"
    ];
    
    # Install required packages
    environment.systemPackages = [
      python
      pkgs.git
      pkgs.curl
      pkgs.jq
      pkgs.gnupg
    ];
    
    # --- Ollama Configuration ---
    services.ollama = {
      enable = true;
      package = pkgs.ollama;
      host = "127.0.0.1";
      port = 11434;
      home = "/var/lib/ollama";
      modelsDir = "/var/lib/ollama/models";
      loadModels = [ "gemma4:12b" ];
      syncModels = true;
      environmentVariables = {
        OLLAMA_NUM_PARALLEL = "1";
        OLLAMA_MAX_LOADED_MODELS = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
      };
    };
    
    # --- News Digest Service ---
    systemd.services.news-digest = {
      description = "News Digest - Daily news processing service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "ollama.service" "news-api.service" ];
      wants = [ "network-online.target" "ollama.service" "news-api.service" ];
      
      serviceConfig = {
        User = newsUser;
        Group = newsGroup;
        StateDirectory = "news";
        ReadWritePaths = [ dataDir ];
        EnvironmentFile = envFile;
        
        ExecStart = "${python}/bin/python3 ${runnerScript}";
        
        # Service settings
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = "30";
        TimeoutStartSec = "90m";
        
        # Security hardening
        ProtectSystem = "full";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        PrivateUsers = true;
        
        # Resource limits
        MemoryMax = "12G";
        TasksMax = 64;
        
        # Priority
        Nice = -5;
        
        # Network
        NetworkIPAccounting = true;
      };
    };
    
    # --- News API Service (for external AI webhook) ---
    systemd.services.news-api = {
      description = "News Digest API - External AI webhook endpoint";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      
      serviceConfig = {
        User = newsUser;
        Group = newsGroup;
        StateDirectory = "news";
        ReadWritePaths = [ dataDir ];
        EnvironmentFile = envFile;
        
        ExecStart = "${python}/bin/python3 ${repoPath}/api/server.py --port ${toString cfg.apiPort} --bind 0.0.0.0";
        
        # Service type - long-running server
        Type = "simple";
        
        # Security
        ProtectSystem = "full";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        
        # Keep alive
        Restart = "on-failure";
        RestartSec = "5";
        
        # Network
        NetworkIPAccounting = true;
      };
    };
    
    # --- News Digest Timer ---
    systemd.timers.news-digest = {
      description = "News Digest - Daily timer";
      wantedBy = [ "timers.target" ];
      
      timerConfig = {
        OnCalendar = "*-*-* ${cfg.schedule}:00";
        Persistent = true;
        RandomizedDelaySec = "0";
        AccuracySec = "1m";
      };
    };
    
    # --- News Archival Timer ---
    systemd.timers.news-archival = {
      description = "News Digest - Nightly git archival";
      wantedBy = [ "timers.target" ];
      
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
        RandomizedDelaySec = "0";
      };
    };
    
    # --- Archival Service ---
    systemd.services.news-archival = {
      description = "News Digest - Git archival of digests";
      after = [ "news-digest.service" ];
      
      serviceConfig = {
        User = newsUser;
        Group = newsGroup;
        StateDirectory = "news";
        ReadWritePaths = [ dataDir ];
        EnvironmentFile = envFile;
        
        ExecStart = ''
          cd ${repoPath}
          git add data/digests
          git commit -m "Archival: digest for $(date +%Y-%m-%d)" --author="${cfg.gitName} <${cfg.gitEmail}>"
          git push ${cfg.gitRemote} main
        '';
        
        Type = "oneshot";
        TimeoutStartSec = "30m";
        
        ProtectSystem = "full";
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
    };
    
    # --- Nginx Configuration ---
    # Note: This VM runs behind a reverse proxy that terminates TLS
    # and handles domain routing. Nginx on the VM serves internal traffic only.
    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      
      # Trust proxy headers since we're behind a reverse proxy
      # Use recommendedProxySettings for standard proxy header handling
      recommendedProxySettings = true;
      
      # Virtual host for internal traffic (from reverse proxy)
      virtualHosts."0.0.0.0:80" = {
        enableACME = false;
        default = true;
        
        # Trust the Host header from the reverse proxy
        serverName = "_";
        
        # Serve from webroot directory (set via extraConfig since documentRoot is deprecated)
        extraConfig = ''
          root ${cfg.webrootPath};
        '';
        
        locations."/" = {
          extraConfig = "try_files $uri $uri/ $uri/index.html;";
        };
        
        # Add cache control headers for JSON files
        locations."/{yr}/{mo}/{d}/digest.json" = {
          extraConfig = "add_header X-Robots-Tag none; add_header Cache-Control \"public, max-age=3600\";";
        };
        
        # Archive JSON - cache for 5 minutes
        locations."/archive/all-years.json" = {
          extraConfig = "add_header Cache-Control \"public, max-age=300\";";
        };
        
        # API proxy for external AI webhook
        locations."/api/" = {
          extraConfig = ''
            proxy_pass http://127.0.0.1:${toString cfg.apiPort};
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
          '';
        };
      };
    };
    
    # --- Environment File ---
    # This is created by the user; /etc/news directory is created via tmpfiles above
    
    # --- Firewall ---
    # Allow HTTP (80) and optionally HTTPS (443) in the future
    networking.firewall.allowedTCPPorts = [ 80 ];
    
    # --- Timezone ---
    time.timeZone = "Europe/Oslo";
    
    # --- Journal Persistence ---
    services.journald.storage = "persistent";
  };
}
