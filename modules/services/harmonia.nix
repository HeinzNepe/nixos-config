{ config, pkgs, vars, ... }:

{
    # Harmonia - Nix binary cache server
    # https://github.com/nix-community/harmonia

    services.harmonia = {
        enable = true;
        # Generate a public/private key pair like this:
        # $ nix-store --generate-binary-cache-key cache.yourdomain.tld-1 /var/lib/secrets/harmonia.secret /var/lib/secrets/harmonia.pub
        # Then commit /var/lib/secrets/harmonia.pub to this repo so clients can add it as a trusted-public-key.
        signKeyPaths = [ "/var/lib/secrets/harmonia.secret" ];
        # To use sops-nix for the signing key instead:
        # signKeyPaths = [ config.sops.secrets.harmonia-key.path ];
        # sops.secrets.harmonia-key = { };
        settings = {
            bind = "0.0.0.0:5000";
        };
    };

    # Allow harmonia to access the Nix store without breaking access for other users
    nix.settings.allowed-users = [ "@wheel" "harmonia" ];

    # Expose harmonia directly on port 5000 (no reverse proxy)
    networking.firewall.allowedTCPPorts = [ 5000 ];

    # To use nginx as a reverse proxy with TLS, uncomment and configure the following:
    # security.acme.defaults.email = "your@email.com";
    # security.acme.acceptTerms = true;
    # networking.firewall.allowedTCPPorts = [ 80 443 ];
    # services.nginx = {
    #   enable = true;
    #   recommendedTlsSettings = true;
    #   virtualHosts."nixcache.example.com" = {
    #     enableACME = true;
    #     forceSSL = true;
    #     locations."/".extraConfig = ''
    #       proxy_pass http://127.0.0.1:5000;
    #       proxy_set_header Host $host;
    #       proxy_redirect http:// https://;
    #       proxy_http_version 1.1;
    #       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #       proxy_set_header Upgrade $http_upgrade;
    #       proxy_set_header Connection $connection_upgrade;
    #     '';
    #   };
    # };
}