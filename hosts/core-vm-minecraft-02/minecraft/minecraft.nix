{ config, pkgs, lib, ... }:

{
  # Install Java 21 headless for running the ATM10 Sky server
  environment.systemPackages = with pkgs; [
    openjdk21_headless
    screen
  ];

  # Ensure the minecraft directory exists and has correct permissions
  systemd.tmpfiles.rules = [
    "d /minecraft 0755 henrik henrik -"
    "d /minecraft/atm10-sky 0755 henrik henrik -"
  ];

  # Systemd service for the ATM10 Sky Minecraft server
  systemd.services.minecraft-atm10-sky = {
    description = "ATM10 Sky Minecraft Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    
    # Run as the henrik user
    user = "henrik";
    group = "henrik";
    
    # Working directory
    workingDirectory = "/minecraft/atm10-sky";
    
    # Use screen to allow attaching to the session
    # Screen session name: minecraft-atm10-sky
    # This allows attaching with: screen -r minecraft-atm10-sky
    execStart = ''
      ${pkgs.bash}/bin/bash -c '
        ${pkgs.coreutils}/bin/chown -R henrik:henrik /minecraft/atm10-sky
        exec ${pkgs.screen}/bin/screen -dmS minecraft-atm10-sky ${pkgs.bash}/bin/bash /minecraft/atm10-sky/run.sh
      '
    '';
    
    # Stop the screen session gracefully
    execStop = ''
      ${pkgs.screen}/bin/screen -S minecraft-atm10-sky -X quit
    '';
    
    # Restart behavior
    restartIfChanged = true;
    restartIfFailed = true;
    
    # Service type - simple since screen will manage the session
    serviceConfig = {
      Type = "simple";
      RemainAfterExit = false;
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "minecraft-atm10-sky";
      
      # Allow the service to be stopped by SIGTERM
      TimeoutStopSec = "60";
      KillMode = "control-group";
      
      # Environment variables for the service
      Environment = [
        "JAVA_HOME=${pkgs.openjdk21_headless}/lib/openjdk"
        "PATH=${pkgs.openjdk21_headless}/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin"
        "HOME=/home/henrik"
        "USER=henrik"
      ];
      
      # Ensure the service has access to the minecraft directory
      SupplementaryGroups = [ "henrik" ];
      WorkingDirectory = "/minecraft/atm10-sky";
      UMask = "0002";
    };
  };
}