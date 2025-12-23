{ inputs, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    modrinth-app

  ];

  # Steam
  programs.steam.enable = true;
}
