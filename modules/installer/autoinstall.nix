{ config, pkgs, lib, vars, ... }:

{
  imports = [
    ../region.nix
  ];


  # Boot configuration for legacy BIOS (GRUB, no EFI)
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.efiSupport = false;
  boot.loader.grub.useOSProber = false; # Optional, for dual-boot
  boot.loader.systemd-boot.enable = false;

  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Add a standard user for installation purposes
  users.users.henrik = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = vars.standardPasswordHash;  # Generate with: mkpasswd -m sha-512
    openssh.authorizedKeys.keys = [
        vars.sshPublicKeyPersonal
    ];
  };

  # Nixos user configuration for auto-installation
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      vars.sshPublicKeyPersonal 
    ];
  };

  # Message of the day for installation guidance
  users.motd = ''
  Welcome to the HeinzNepe ISO installer!

  To install the system, copy and paste the following command:

  sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/HeinzNepe/nixos-config/main/install.sh)"

  '';

  # Enable SSH for remote access during installation
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  # Allow passwordless sudo for wheel group during installation
  security.sudo.wheelNeedsPassword = false;


  # Optional: auto-login or post-install hooks
  system.stateVersion = "25.11";
}
