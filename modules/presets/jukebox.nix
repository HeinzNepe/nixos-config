{ pkgs, config, ... }:
{
    nixpkgs.overlays = [ (import ./overlay-shairport.nix) ];

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
            alsa = {
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
