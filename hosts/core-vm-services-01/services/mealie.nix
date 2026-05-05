{ config, lib, pkgs, ... }:

{
    services.mealie = {
        enable = true;
        port = 9925;
        settings = {
            # The publicly accessible URL of your Mealie instance
            BASE_URL = "https://mealie.topheinz.com";
        };
    };
}