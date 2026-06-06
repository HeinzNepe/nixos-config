# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ modulesPath, config, pkgs, vars, lib, ... }:

{
  # NixosAnywhere needs kexec-tools
  # apt install kexec-tools

  # Nixos anywhere can be ran with the following command
  # nix run github:nix-community/nixos-anywhere -- --flake .#no-vps-01 no-vps-01 
  # nix run github:nix-community/nixos-anywhere -- --flake .#no-vps-01 --generate-hardware-config nixos-generate-config ./hardware-configuration.nix no-vps-01

  imports =
    [ 
      # Defaults
      ../../modules/nix-options.nix
      ../../modules/region.nix
      ../../modules/cli-programs.nix

      # Add dev modules
      ../../modules/options/fonts.nix
      ../../modules/options/shell.nix
      ../../modules/options/docker.nix
      ../../modules/options/networking-tools.nix
      ../../modules/options/ssh-server.nix

      # Include the static network configuration for the VPS
      ./networking.nix

      # Include the results of the hardware scan.
      #./hardware-configuration.nix
      (modulesPath + "/profiles/qemu-guest.nix")
      #"${pkgs.path}/nixos/modules/profiles/qemu-guest.nix"
      ./disko.nix # Disko for disk formatting
    ];

  networking.hostName = "no-vps-01"; # Define your hostname.
  
  # Enable networking with DHCP for all non-configured links
  #networking.networkmanager.enable = true;

  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.henrik = {
    isNormalUser = true;
    description = "Henrik Nepstad";
    #extraGroups = [ "networkmanager" "wheel" "docker" ];
    extraGroups = [ "wheel" "docker" ];
    hashedPassword = vars.hashedPassword;
    openssh.authorizedKeys.keys = [
      vars.sshPublicKeyPersonal
    ];
    packages = with pkgs; [
      #package
    ];
  };

  # Bootloader (Systemd-boot is recommended for UEFI systems)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and nix-command for advanced Nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
