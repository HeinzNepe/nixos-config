{ config, lib, pkgs, ... }:

{
    services.mealie = {
        enable = true;
        settings = {
            # The publicly accessible URL of your Mealie instance
            BASE_URL = "https://mealie.topheinz.com";
        };
    };

    networking.firewall.allowedTCPPorts = [ 9000 ]; # Allow Mealie's port through the firewall
}