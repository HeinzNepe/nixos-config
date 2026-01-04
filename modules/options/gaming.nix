{ inputs, pkgs, pkgs-stable, ... }:

{
  # Add gaming related packages to system environment
  environment.systemPackages = with pkgs; [
    # From unstable channel

    # Tetris desktop game
    tetrio-desktop
  ] ++ (with pkgs-stable; [
    # From stable channel
    #modrinth-app # Modrinth client for Minecraft mods. (Currently broken)

  ]);

  # Steam
  programs.steam.enable = true;
}
