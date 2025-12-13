{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vivaldi
    spotify
    discord
    vscode
  ];

}

