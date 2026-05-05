{ config, lib, pkgs, ... }:

{
    services.mealie = {
        enable = true;
        port = 9925;
        settings = {
            # The publicly accessible URL of your Mealie instance
            BASE_URL = "https://mealie.topheinz.com";

            # Allow new users to register themselves (set to false to invite-only)
            ALLOW_SIGNUP = false;

        };
    };
}