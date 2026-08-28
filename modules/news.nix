{ config, pkgs, lib, ... }:

# News Digest NixOS Module
# This module provides all the services needed for the News Digest service

with lib;

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
    enable = mkOptionDefault true "Enable the News Digest service";
    
    # Service configuration
    schedule = mkOptionDefault "06:30" "Daily run time (HH:MM) in Europe/Oslo timezone";
    selfUrl = mkOptionDefault "https://news.nepstad.it" "Base URL for the news digest site";
    apiPort = mkOptionDefault 8080 "Port for the external AI webhook API";
    externalAiTimeoutMinutes = mkOptionDefault 10 "Timeout in minutes for external AI";
    externalAiApiKey = mkOptionDefault "" "Optional API key for external AI authentication";
    keepRawDays = mkOptionDefault 7 "Number of days to keep raw feed data";
    keepArchivesYears = mkOptionDefault 10 "Number of years to keep digest archives";
    
    # Repository path (where the code is installed)
    repoPath = mkOptionDefault "/opt/news" "Path to the news digest repository";
    
    # Git configuration for archival
    gitRemote = mkOptionDefault "origin" "Git remote name for archival push";
    gitEmail = mkOptionDefault "" "Git commit email for archival";
    gitName = mkOptionDefault "News Digest" "Git commit name for archival";
  };

  config = mkIf cfg.enable {
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
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${rawDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${digestsDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${staticDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${stateDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${runDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${pendingDir} 0755 ${newsUser} ${newsGroup} - -"
      "d ${dataDir}/source-probe 0755 ${newsUser} ${newsGroup} - -"
      "d ${dataDir}/log 0755 ${newsUser} ${newsGroup} - -"
      "d ${config.services.news.repoPath} 0755 root root - -"
    ] ++ (config.systemd.tmpfiles.rules or []);
    
    # Install required packages
    environment.systemPackages = (config.environment.systemPackages or []) ++ [
      python
      pkgs.git
      pkgs.curl
      pkgs.jq
      pkgs.gnupg
    ];
    
    # --- Ollama Configuration ---
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cpu;
      host = "127.0.0.1";
      port = 11434;
      home = "/var/lib/ollama";
      models = "/var/lib/ollama/models";
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
      wants = [ "ollama.service" "news-api.service" ];
      
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
      proxyHeaders = {
        enable = true;
        trusted = [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" "127.0.0.1" ];
      };
      
      # Virtual host for internal traffic (from reverse proxy)
      virtualHosts."0.0.0.0:80" = {
        enableACME = false;
        default = true;
        documentRoot = staticDir;
        
        # Trust the Host header from the reverse proxy
        serverName = "_";
        
        locations."/" = {
          config = "try_files $uri $uri/ $uri/index.html;";
        };
        
        # Add cache control headers for static content
        locations."/{yr}/{mo}/{d}/index.html" = {
          addHeader = "X-Robots-Tag none";
          addHeader = "Cache-Control public, max-age=3600";
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
    # This is created by the user; we provide the directory
    environment.etc."news/news.env".mode = "0600";
    environment.etc."news/news.env".user = newsUser;
    environment.etc."news/news.env".group = newsGroup;
    
    # --- Firewall ---
    # Allow HTTP (80) and optionally HTTPS (443) in the future
    networking.firewall.allowedTCPPorts = [ 80 ];
    
    # --- Timezone ---
    time.timeZone = "Europe/Oslo";
    
    # --- Journal Persistence ---
    services.journald.persistent = true;
  };
}
