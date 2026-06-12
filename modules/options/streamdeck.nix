# Configuration for Stream Deck device on NixOS
# This module assumes necessary hardware support is handled elsewhere
# (e.g., input drivers, service definitions).

{ pkgs, config, lib, ... }:

{


  programs.streamdeck-ui {
    enable = true; # Enable the Stream Deck UI program
    autoStart = true; # Start the program automatically on login
  }
}