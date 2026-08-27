{ inputs, pkgs, pkgs-stable, ... }:

{
  # Mistral related packages to system environment
  environment.systemPackages = [
    # From unstable channel
    pkgs.mistral-vibe
  ];

}
