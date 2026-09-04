# minecraft.nix
# Manual Minecraft Server Configuration for ATM10 Sky
# Server files are pre-downloaded at /minecraft/atm10-manual/
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

  # Create the minecraft directory
  systemd.tmpfiles.rules = [
    "d /opt/minecraft 0755 minecraft minecraft - -"
    "d /opt/minecraft/atm10-sky 0755 minecraft minecraft - -"
  ];

  # Manual Minecraft Server service using screen
  systemd.services.minecraft-atm10-sky = {
    description = "Minecraft Server: ATM10 Sky";
    
    after = [ "network.target" ];
    
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = "/minecraft/atm10-manual";
      Restart = "always";
      RestartSec = "10";
      
      # Start the server using the startserver.sh script
      ExecStart = "${pkgs.screen}/bin/screen -DmS mc-atm10-sky /bin/bash /minecraft/atm10-manual/startserver.sh";
      
      # Graceful shutdown sequence - combined into single ExecStop
      ExecStop = "${pkgs.bash}/bin/bash -c '\n        ${pkgs.screen}/bin/screen -p 0 -S mc-atm10-sky -X eval 'stuff \"say SERVER SHUTTING DOWN IN 5 SECONDS. SAVING ALL MAPS...\"\\015' &&\n        ${pkgs.coreutils}/bin/sleep 5 &&\n        ${pkgs.screen}/bin/screen -p 0 -S mc-atm10-sky -X eval 'stuff \"save-all\"\\015' &&\n        ${pkgs.screen}/bin/screen -p 0 -S mc-atm10-sky -X eval 'stuff \"stop\"\\015'\n      '";
      
      # Environment variables for Java and screen
      Environment = [
        "JAVA_HOME=${pkgs.jdk21}/lib/openjdk"
        "PATH=${pkgs.jdk21}/bin:${pkgs.screen}/bin:${pkgs.coreutils}/bin:${pkgs.procps}/bin:${pkgs.bash}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      ];
    };
  };

  # Open firewall port for the server
  networking.firewall.allowedTCPPorts = [ 25566 ];
}