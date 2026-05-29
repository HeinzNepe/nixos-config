{ inputs, pkgs, pkgs-stable, ... }:

{
  # Add gaming related packages to system environment
  environment.systemPackages = with pkgs; [
    # From unstable channel

    # Tetris desktop game
    tetrio-desktop
    modrinth-app # Modrinth client for Minecraft mods.

  ] ++ (with pkgs-stable; [
    # From stable channel
    #modrinth-app # Modrinth client for Minecraft mods.

  ]);

  # Steam
  programs.steam.enable = true;
}
