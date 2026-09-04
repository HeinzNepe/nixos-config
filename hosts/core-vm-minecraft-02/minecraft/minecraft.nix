# minecraft.nix
# Manual Minecraft Server Configuration for ATM10 Sky

{
  config,
  pkgs,
  lib,
  ...
}:

{
  environment.systemPackages = [ pkgs.jdk21 pkgs.screen ];

  users.groups.minecraft = {};
  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
  };

  systemd.tmpfiles.rules = [
    "d /run/minecraft 0700 minecraft minecraft - -"
  ];

  systemd.services.minecraft-atm10-sky = {
    description = "Minecraft Server: ATM10 Sky";

    after = [ "network.target" "systemd-tmpfiles-setup.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "forking";
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = "/minecraft/atm10-sky";

      Restart = "on-failure";
      RestartSec = "30";

      ExecStart = "${pkgs.writeShellScriptBin \"start-minecraft\" ''
        #!${pkgs.bash}/bin/bash
        export SCREENDIR=/run/minecraft
        mkdir -p "$SCREENDIR"
        chmod 700 "$SCREENDIR"
        exec ${pkgs.screen}/bin/screen -dmS mc-atm10-sky /bin/bash /minecraft/atm10-sky/run.sh
      ''}";

      ExecStop = "${pkgs.screen}/bin/screen -p 0 -S mc-atm10-sky -X quit";

      Environment = [
        "JAVA_HOME=${pkgs.jdk21}/lib/openjdk"
        "PATH=${pkgs.jdk21}/bin:${pkgs.screen}/bin:${pkgs.coreutils}/bin:${pkgs.procps}/bin:${pkgs.bash}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        "TERM=xterm-256color"
        "SCREENDIR=/run/minecraft"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 25566 ];
}