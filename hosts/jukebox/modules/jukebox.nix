{ config, pkgs, lib, ... }:

# NixOS module for the jukebox host
# Provides AirPlay (shairport-sync) audio output to aux via ALSA

{
  # System user and group for shairport-sync
  users = {
    users.shairport = {
      description    = "Shairport user";
      isSystemUser   = true;
      createHome     = true;
      home           = "/var/lib/shairport-sync";
      group          = "shairport";
      extraGroups    = [ "audio" ]; # Needed for ALSA device access
    };
    groups.shairport = {};
  };

  # Open required firewall ports for AirPlay and mDNS
  networking.firewall = {
    interfaces."wlp0s20f3" = {
      allowedTCPPorts = [
        3689
        5353
        5000
        7000
      ];
      allowedUDPPorts = [
        5353
      ];
      allowedTCPPortRanges = [
        { from = 32768; to = 60999; }
      ];
      allowedUDPPortRanges = [
        { from = 319; to = 320; }
        { from = 6000; to = 6009; }
        { from = 32768; to = 60999; }
      ];
    };
  };

  # Essential packages for audio and AirPlay
  environment = {
    systemPackages = with pkgs; [
      alsa-utils
      nqptp
      shairport-sync-airplay2
    ];
  };

  # Enable Avahi for mDNS/Bonjour discovery (required for AirPlay)
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
    allowInterfaces = [ "wlp0s20f3" ];
  };

  # Systemd services: nqptp for AirPlay 2 timing, shairport-sync for AirPlay audio
  systemd.services = {
    nqptp = {
      description = "Network Precision Time Protocol for Shairport Sync";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.nqptp}/bin/nqptp";
        Restart = "always";
        RestartSec = "5s";
      };
    };
    nix-jukebox = {
      description = "nix-jukebox shairport-sync instance";
      wantedBy = [ "multi-user.target" ];
      after       = [ "network.target" "avahi-daemon.service" ]; # Ensure network and Avahi are up
      serviceConfig = {
        User             = "shairport";
        Group            = "shairport";
        ExecStart = "${pkgs.shairport-sync-airplay2}/bin/shairport-sync -c /etc/nix-jukebox.conf";
        Restart          = "on-failure";
        RuntimeDirectory = "shairport-sync";
      };
    };
  };

  # Write shairport-sync config for ALSA output
  environment.etc."nix-jukebox.conf".text = ''
    general =
    {
      name = "nix-jukebox";
      output_backend = "alsa"; # Use ALSA directly (no PulseAudio/PipeWire)
      port = 7000;
    };

    alsa =
    {
      output_device = "plughw:sofhdadsp,0"; # Card name for aux output, with plug for format conversion

    # For volume control and troubleshooting:
    # - Use `alsamixer` to adjust output levels
    # - Use `alsactl store` to persist volume settings
    };
  '';
}