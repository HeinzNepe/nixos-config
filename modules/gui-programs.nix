{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vivaldi
    firefox
    spotify
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

