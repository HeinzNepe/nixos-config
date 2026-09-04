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

  # Set minecraft user home to a writable directory
  users.groups.minecraft = {};
  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
    home = "/minecraft";  # Fixed: set home to writable directory
  };

  systemd.tmpfiles.rules = [
    "d /minecraft 0755 minecraft minecraft - -"
    "d /minecraft/atm10-sky 0755 minecraft minecraft - -"
    "d /minecraft/.screen 0700 minecraft minecraft - -"  # Fixed: screen socket dir in home
  ];

  systemd.services.minecraft-atm10-sky = {
    description = "Minecraft Server: ATM10 Sky";

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = "/minecraft/atm10-sky";

      Restart = "always";
      RestartSec = "10";

      # Match your working example
      ExecStart = "${pkgs.screen}/bin/screen -DmS mc-atm10-sky /bin/bash /minecraft/atm10-sky/run.sh";

      # Multiple ExecStop directives via a script
      ExecStop = "${pkgs.writeShellScriptBin \"stop-minecraft\" ''
        #!${pkgs.bash}/bin/bash
        ${pkgs.screen}/bin/screen -p 0 -S mc-atm10-sky -X eval 'stuff \"say SERVER SHUTTING DOWN IN 5 SECONDS. SAVING ALL MAPS...\"\\015'
        ${pkgs.coreutils}/bin/sleep 5
        ${pkgs.screen}/bin/screen -p 0 -S mc-atm10-sky -X eval 'stuff \"save-all\"\\015'
        ${pkgs.screen}/bin/screen -p 0 -S mc-atm10-sky -X eval 'stuff \"stop\"\\015'
      ''}";

      Environment = [
        "JAVA_HOME=${pkgs.jdk21}/lib/openjdk"
        "PATH=${pkgs.jdk21}/bin:${pkgs.screen}/bin:${pkgs.coreutils}/bin:${pkgs.procps}/bin:${pkgs.bash}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        "TERM=xterm-256color"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 25566 ];
}