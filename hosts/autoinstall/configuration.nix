{ config, pkgs, pkgs-stable, vars, ... }:

{
  imports = [
    ./autoinstall.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
