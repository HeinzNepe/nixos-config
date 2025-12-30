{ inputs, pkgs, ... }:

{
  # Add gaming related packages to system environment
  environment.systemPackages = with pkgs; [
    # Tetris desktop game
    tetrio-desktop
  ];

  # Steam
  programs.steam.enable = true;
}
