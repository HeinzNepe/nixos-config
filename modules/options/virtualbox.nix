{ inputs, pkgs, pkgs-stable, ... }:

{
  # Add virtualbox to system environment
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
