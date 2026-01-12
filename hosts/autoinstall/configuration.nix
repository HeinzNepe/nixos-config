{ config, pkgs, vars, ... }:

{
  imports = [
    ../../modules/installer/autoinstall.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
