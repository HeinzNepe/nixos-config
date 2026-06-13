# Configuration for Stream Deck device on NixOS
# This module assumes necessary hardware support is handled elsewhere
# (e.g., input drivers, service definitions).

{ pkgs, config, lib, ... }:

{
  # Not the Windows Stream Deck software, but an open-source alternative for Linux. 
  # Need to see if i find an alternative thats better
  programs.streamdeck-ui = {
    enable = true; # Enable the Stream Deck UI program
    autoStart = true; # Start the program automatically on login
  };
}