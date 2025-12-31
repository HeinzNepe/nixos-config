{ pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    # Obsidian note-taking app
    obsidian

    # Spotify music streaming app
    spotify
  ];
}