{ inputs, pkgs, ... }:

{

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 8";
    flake = "/home/henrik/GitHub/nixos-config"; # sets NH_OS_FLAKE variable for you
  };


  # Remove old generations
  #nix.gc = {
  #  automatic = true;
  #  dates = "weekly";
  #  options = "--delete-older-than 7d";
  #};

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Overlay for nvchad
  # TODO: Move this somewhere else
  nixpkgs.overlays = [
    (final: prev: {
      nvchad = inputs.nix4nvchad.packages."${pkgs.system}".nvchad;
    })
  ];
}
