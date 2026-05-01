# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, vars, ... }:

{
  imports =
    [ 
      # Defaults
      ../../modules/desktop.nix
      
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

  networking.hostName = "eagle-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking with DHCP for all non-configured links
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

  # Bootloader
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable hardware accelerated graphics (Do i need this?)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Monitor and workspace configuration for hyprland
  home-manager.sharedModules = [
    {
      wayland.windowManager.hyprland.settings = {
        monitor = [
          "HDMI-A-1, 1920x1080@120, 0x180, 1"
          "DP-2, 3440x1440@165, 1920x0, 1"
          "DP-1, 1920x1080@144, 5360x180, 1"
        ];
        workspace = [
          "1, monitor:HDMI-A-1, default:true"
          "2, monitor:HDMI-A-1"
          "3, monitor:DP-2, default:true"
          "4, monitor:DP-2"
          "5, monitor:DP-1, default:true"
          "6, monitor:DP-1"
        ];
      };
    }
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and nix-command for advanced Nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
