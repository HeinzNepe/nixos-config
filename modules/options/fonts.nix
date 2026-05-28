{ config, lib, pkgs, ... }:

{
    fonts.enableDefaultPackages = true;
    fonts.fontconfig.enable = true;
    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        roboto

        # Additional fonts for better compatibility with e.g. GeoGuessr
        noto-fonts
        noto-fonts-color-emoji
        liberation_ttf
        dejavu_fonts
    ];

    environment.sessionVariables = {
        FONTCONFIG_PATH = "${pkgs.fontconfig}/etc/fonts";
    };
}