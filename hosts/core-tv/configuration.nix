# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-stable, vars, ... }:

{
  imports =
    [ 
      # Defaults
      ../../modules/desktop-autologin.nix
      
      ../../modules/nix-options.nix
      ../../modules/region.nix
      ../../modules/cli-programs.nix
      ../../modules/options/bluetooth.nix

      # Optional modules
      # Applications
      ../../modules/gui-programs.nix

      # Add dev modules
      ../../modules/options/development.nix
      ../../modules/options/fonts.nix
      ../../modules/options/shell.nix
      ../../modules/options/vpn.nix
      ../../modules/options/networking-tools.nix

      # Home-manager
      ../../homemanager.nix

      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "core-tv"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

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



  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
