{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vivaldi
    discord
    spotify
    vscode 
  ];

}



