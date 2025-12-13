{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vivaldi
    firefox
    spotify
    discord
    vscode
  ];

}

