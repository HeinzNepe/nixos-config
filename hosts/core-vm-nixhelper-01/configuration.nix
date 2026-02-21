# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, vars, ... }:

{
  imports =
    [ 
      # Defaults
      ../../modules/nix-options.nix
      ../../modules/region.nix
      ../../modules/cli-programs.nix
      ../../modules/sops.nix

      # Optional modules
      
      # Add dev modules
      ../../modules/options/fonts.nix
      ../../modules/options/shell.nix
      ../../modules/options/docker.nix
      ../../modules/options/networking-tools.nix
      ../../modules/options/ssh-server.nix

      # Gitea module
      ../../modules/options/gitea.nix

      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  networking.hostName = "core-vm-nixhelper-01"; # Define your hostname.
  
  # Enable networking
  networking.networkmanager.enable = true;

  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.henrik = {
    isNormalUser = true;
    description = "Henrik Nepstad";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    hashedPassword = vars.hashedPassword;
    openssh.authorizedKeys.keys = [
      vars.sshPublicKeyPersonal
    ];
    packages = with pkgs; [
      #package
    ];
  };

  # Bootloader (grub since its non-uefi)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;

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
