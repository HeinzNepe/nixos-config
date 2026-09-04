# minecraft.nix
# Manual Minecraft Server Configuration for ATM10 Sky
# Uses Java 21 and screen for process management

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Ensure Java 21 and screen are available
  environment.systemPackages = [ pkgs.jdk21 pkgs.screen ];

  # Create minecraft user and group
  users.groups.minecraft = {};
  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
  };

  # Create the minecraft directory and screen socket directory
  systemd.tmpfiles.rules = [
    "d /minecraft 0755 minecraft minecraft - -"
    "d /minecraft/atm10-sky 0755 minecraft minecraft - -"
    "d /run/minecraft 0755 minecraft minecraft - -"
  ];

  # Manual Minecraft Server service using screen
  systemd.services.minecraft-atm10-sky = {
    description = "Minecraft Server: ATM10 Sky";

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = "/minecraft/atm10-sky";

      # Prevent rapid restart loop
      Restart = "on-failure";
      RestartSec = "30";
      StartLimitInterval = 120;  # Fixed: removed Sec suffix
      StartLimitBurst = 3;

      # Start the server using the existing run.sh script
      ExecStart = "${pkgs.screen}/bin/screen -DmS mc-atm10-sky /bin/bash /minecraft/atm10-sky/run.sh";

      # Simple ExecStop - just kill the screen session
      ExecStop = "${pkgs.screen}/bin/screen -p 0 -S mc-atm10-sky -X quit";

      Environment = [
        "JAVA_HOME=${pkgs.jdk21}/lib/openjdk"
        "PATH=${pkgs.jdk21}/bin:${pkgs.screen}/bin:${pkgs.coreutils}/bin:${pkgs.procps}/bin:${pkgs.bash}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        "TERM=xterm-256color"
        "SCREENDIR=/run/minecraft"  # Fixed: screen socket directory
      ];
    };
  };

  # Open firewall port for the server
  networking.firewall.allowedTCPPorts = [ 25566 ];
}