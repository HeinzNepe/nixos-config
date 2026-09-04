# minecraft.nix
# Manual Minecraft Server Configuration for ATM10 Sky

{
  config,
  pkgs,
  lib,
  ...
}:

let
  startScript = pkgs.writeShellScriptBin "start-minecraft" ''
    #!${pkgs.bash}/bin/bash
    export SCREENDIR=/minecraft/.screen
    export HOME=/minecraft
    mkdir -p "$SCREENDIR"
    chmod 700 "$SCREENDIR"
    exec ${pkgs.screen}/bin/screen -dmS mc-atm10-sky ${pkgs.bash}/bin/bash /minecraft/atm10-sky/run.sh
  '';
  stopScript = pkgs.writeShellScriptBin "stop-minecraft" ''
    #!${pkgs.bash}/bin/bash
    export SCREENDIR=/minecraft/.screen
    ${pkgs.screen}/bin/screen -p 0 -S mc-atm10-sky -X quit
  '';
in
{
  environment.systemPackages = [ pkgs.jdk21 pkgs.screen ];

  users.groups.minecraft = {};
  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
    home = "/minecraft";  # Critical: writable home for .screen
  };

  systemd.tmpfiles.rules = [
    "d /minecraft 0755 minecraft minecraft - -"
    "d /minecraft/atm10-sky 0755 minecraft minecraft - -"
    "d /minecraft/.screen 0700 minecraft minecraft - -"  # screen socket directory
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

      Restart = "always";
      RestartSec = "10";

      ExecStart = "${startScript}";

      ExecStop = "${stopScript}";

      Environment = [
        "JAVA_HOME=${pkgs.jdk21}/lib/openjdk"
        "PATH=${pkgs.jdk21}/bin:${pkgs.screen}/bin:${pkgs.coreutils}/bin:${pkgs.procps}/bin:${pkgs.bash}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        "TERM=xterm-256color"
        "SCREENDIR=/minecraft/.screen"
        "HOME=/minecraft"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 25566 ];
}