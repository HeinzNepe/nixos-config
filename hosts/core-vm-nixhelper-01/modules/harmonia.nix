{ config, pkgs, vars, ... }:

{
    # Harmonia - Nix binary cache server
    # https://github.com/nix-community/harmonia

    sops.secrets."harmonia-secret-signing-key" = {
        sopsFile = ./../../../secrets/hosts/core-vm-nixhelper-01.yaml;
        owner = "harmonia";
        group = "harmonia";
        mode = "0400";
    };

    sops.secrets."harmonia-public-signign-key" = {
        sopsFile = ./../../../secrets/hosts/core-vm-nixhelper-01.yaml;
        owner = "harmonia";
        group = "harmonia";
        mode = "0444";
    };

    services.harmonia = {
        enable = true;
        # Generated with `sudo nix-store --generate-binary-cache-key cache.domain-1 \ secret-key.pem public-key.pem`
        signKeyPaths = [ config.sops.secrets."harmonia-secret-signing-key".path ];
        settings = {
            bind = "0.0.0.0:5000";
        };
    };

    # Allow harmonia to access the Nix store without breaking access for other users
    nix.settings.allowed-users = [ "@wheel" "harmonia" ];

    # Expose harmonia directly on port 5000 (no reverse proxy)
    networking.firewall.allowedTCPPorts = [ 5000 ];

}