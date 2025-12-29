{ config, lib, pkgs, ... }:

{
    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        roboto
    ];
}