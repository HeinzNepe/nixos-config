
{ config, pkgs, ... }:

# GUI programs and autostart configuration
# This module installs GUI applications and sets up user services.
{
  # Import additional option modules for productivity and browsers
  imports = [
    ./options/productivity.nix
    ./options/browsers.nix
  ];

  # Install GUI applications system-wide
  environment.systemPackages = with pkgs; [
    discord # Discord chat client
  ];

  # Autostart Discord after Plasma loads using a user systemd service
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

