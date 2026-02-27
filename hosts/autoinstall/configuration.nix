{ config, pkgs, vars, ... }:

{
  imports = [
    autoinstall.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
