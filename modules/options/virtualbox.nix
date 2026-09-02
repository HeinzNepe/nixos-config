{ inputs, pkgs, pkgs-stable, ... }:

{
  # Add virtualbox package to system environment
  environment.systemPackages = [
    # From stable channel
    pkgs-stable.virtualbox
  ];

}
