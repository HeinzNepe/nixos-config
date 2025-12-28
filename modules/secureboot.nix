{ config, pkgs, ... }:

{
  # Disable systemd-boot (Lanzaboote replaces it)
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable Lanzaboote
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";  # Where keys will be stored
    autoEnrollKeys = {
      enable = true; # Enable automatic key enrollment
      autoReboot = true;  # Reboot automatically after enrolling keys
    };
  };


  # Optional but recommended
  boot.kernelParams = [
    "lockdown=integrity"
  ];

  environment.systemPackages = with pkgs; [
    sbctl  # Secure Boot control tool
  ];
}
