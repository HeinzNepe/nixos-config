{ inputs, pkgs, pkgs-stable, ... }:

{
  # Add gaming related packages to system environment
  environment.systemPackages = with pkgs; [
    # From unstable channel

    # Tetris desktop game
    tetrio-desktop
    modrinth-app # Modrinth client for Minecraft mods.

    # Add Java JDK for minecraft
    #jdk8 
    #jdk17 
    #jdk21
    jdk25
  ];

  # Steam
  programs.steam.enable = true;
}
