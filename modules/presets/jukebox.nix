{ pkgs, ... }:
{

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = false;
    };

    services.shairport-sync = {
        enable = true;
        openFirewall = true;
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
