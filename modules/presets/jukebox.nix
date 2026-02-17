{ pkgs, ... }:
{
    # add shairport-sync user
    users.users.shairport = {
      description = "Shairport user";
      isSystemUser = true;
      createHome = true;
      home = "/var/lib/shairport-sync";
      group = "shairport";
      extraGroups = [ "pulse-access" ];
    };
    users.groups.shairport = {};


    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = false;
    };

    services.shairport-sync = {
        enable = true;
        openFirewall = true;
        user = "shairport";
        group = "shairport";
        settings = {
            name = "NixOS-Jukebox";
            audio = {
                output_backend = "ao";
            };
            ao = {
                output_device = "default";
            };
        };
    };

    services.spotifyd = {
        enable = true;
        settings = {
            device_name = "NixOS-Jukebox";
            backend = "pipewire";
        };
    };


}
