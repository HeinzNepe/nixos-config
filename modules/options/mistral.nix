{ inputs, pkgs, pkgs-stable, ... }:

{
  # Mistral related packages to system environment
  environment.systemPackages = [
    # From the official mistral-vibe flake
    inputs.mistral-vibe.packages.${pkgs.system}.default
  ];

  # Add the overlay to make mistral-vibe available in pkgs
  nixpkgs.overlays = [
    (final: prev: {
      mistral-vibe = inputs.mistral-vibe.packages.${pkgs.system}.default;
    })
  ];

}
