{ inputs, pkgs, ... }:

# Nix package manager options and overlays
# This module configures Nix and Nixpkgs options, overlays, and related tools.
{

  # Enable nh (Nix Helper) for easier system management
  programs.nh = {
    enable = true; # Enable nh
    clean.enable = true; # Enable cleaning of old generations
    #clean.extraArgs = "--keep-since 7d --keep 8"; # Keep generations from last 7 days and 8 most recent
    clean.extraArgs = "--keep 8"; # Keep 8 most recent generations
    #flake = "/home/henrik/GitHub/nixos-config"; # Optionally set the flake path for nh
  };

  # Remove old generations automatically (commented out, see nh above)
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 7d";
  # };


 # Enable flakes and nix-command for advanced Nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
