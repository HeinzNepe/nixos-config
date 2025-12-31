{ config, pkgs, ... }:

{
  imports = [
    ./options/productivity.nix
    ./options/browsers.nix
   ];


  environment.systemPackages = with pkgs; [
    discord
  ];


  # Autostart Discord after Plasma loads
  systemd.user.services.discord = {
    name = "discord.service";
    enable = true;
    description = "Autostart Discord after Plasma loads";
    wantedBy = [ "plasma-workspace.target" ];
    after = [ "plasma-workspace.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.discord}/bin/discord";
      Restart = "on-failure";
    };
  };


}

