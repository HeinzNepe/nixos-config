{ pkgs, ... }:
{

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
    };

    services.shairport-sync = {
        enable = true;
        openFirewall = true;
        settings = {
            name = "NixOS-Jukebox";
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
