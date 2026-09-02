{ inputs, pkgs, pkgs-stable, ... }:

{
    # Add gaming related packages to system environment
    environment.systemPackages = [
        # From unstable channel
        pkgs.tetrio-desktop
    ];



    # Steam
    programs.steam = {
    enable = true;
    fontPackages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
    ];
    };

    # Enable hardware accelerated graphics (Do i need this?)
    hardware.graphics = {
    enable = true;
    enable32Bit = true;
    };

}
