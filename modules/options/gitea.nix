{ config, pkgs, lib, ... }:

{
  services.gitea = {
    enable = true;

    # Basic metadata
    appName = "Gitea";
    user = "gitea";
    group = "gitea";

    # Database configuration
    # SQLite (simple, good for small setups)
    database = {
      type = "sqlite3";
      path = "/var/lib/gitea/data/gitea.db";
    };

    # Git over SSH (internal traffic)
    ssh = {
      enable = true;
      port = 2222;  # Internal SSH port for Git
    };

    settings = {
      server = {
        DOMAIN = "git.core.topheinz.com";  # Internal hostname for SSH
        SSH_DOMAIN = "git.core.topheinz.com";
        HTTP_PORT = 3000;
        ROOT_URL = "https://git.core.topheinz.com/";  # Pangolin-facing URL
      };

      # Optional: disable registration
      service = {
        DISABLE_REGISTRATION = true;
      };
    };
  };

  # Firewall rules
  networking.firewall.allowedTCPPorts = [
    3000  # HTTP to reach Gitea
    2222  # Git over SSH
  ];

}
