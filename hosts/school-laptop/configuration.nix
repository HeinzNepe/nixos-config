# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, vars, ... }:

{
  imports =
    [ 
      # Defaults
      ../../modules/desktop.nix
      ../../modules/options/audio.nix
      ../../modules/nix-options.nix
      ../../modules/region.nix
      ../../modules/cli-programs.nix
      ../../modules/sops.nix

      # Optional modules
      # Applications
      ../../modules/gui-programs.nix

      # Add dev modules
      ../../modules/options/development.nix
      ../../modules/options/git.nix
      ../../modules/options/fonts.nix
      ../../modules/options/shell.nix
      ../../modules/options/vpn.nix
      ../../modules/options/docker.nix
      ../../modules/options/networking-tools.nix

      # Cisco Packet Tracer (remember to add to nixcache)
      #../../modules/options/packet-tracer.nix

      # Java JDK 25 ++
      #../../modules/options/tdt4100.nix

      # Add password manager
      ../../modules/1password.nix

      # Add gaming module
      ../../modules/options/gaming.nix

      # Home-manager
      ../../homemanager.nix
     

      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Secure Boot
      ../../modules/options/secureboot.nix
    ];

  networking.hostName = "school-laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable secureboot
  #custom.security.secureBoot.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.henrik = {
    isNormalUser = true;
    description = "Henrik Nepstad";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      #package
    ];
    hashedPassword = vars.hashedPassword;
    openssh.authorizedKeys.keys = [
      vars.sshPublicKeyPersonal
    ];
  };

  # Bootloader
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
