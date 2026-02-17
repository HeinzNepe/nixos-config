{
  # Flake for NixOS with importable Secure Boot module (lanzaboote + sbctl)
  description = "Henrik's flake";

  # Define the inputs used for the flake
  inputs = {
    # Add nixpkgs input under the unstable channel
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Add nixpkgs-stable input for stable packages
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Lanzaboote for Secure Boot support
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager for user-level configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plasma Manager for KDE Plasma configuration
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DIsko for disk management and auto-installation support
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Sops-nix for managing secrets in NixOS configurations
    sops-nix ={
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Define the NixOS configurations for different hosts
  # Each host has its own configuration.nix file that imports common modules and defines host-specific settings
  outputs = { self, nixpkgs, nixpkgs-stable, lanzaboote, home-manager, plasma-manager, disko, sops-nix, ... }@inputs:
    # The outputs function generates the NixOS configurations for each host and the auto-installation ISO configuration.
    let
      # Import the variables from vars.nix
      vars = import ./vars.nix;
      
      # Define a helper function to create NixOS configurations for each host
      mkNixOSConfig = path: extraModules: nixpkgs.lib.nixosSystem {
        # Pass the inputs and variables to the NixOS configuration for use in the configuration.nix files
        specialArgs = { inherit inputs vars; };
        # Define modules to be included for all hosts, and append any extra modules specific to the host
        modules = [ path sops-nix.nixosModules.sops ] ++ extraModules;
      };
    in {
      nixosConfigurations = {
        # Define NixOS configurations for different hosts
        
        # Homelab configuration
        core-vm-gitea-01 = mkNixOSConfig ./hosts/core-vm-gitea-01/configuration.nix [];

        # Jukebox laptop configuration
        jukebox = mkNixOSConfig ./hosts/jukebox/configuration.nix [];
        
        # Desktop configuration
        desktop = mkNixOSConfig ./hosts/desktop/configuration.nix [ lanzaboote.nixosModules.lanzaboote ];
        
        # School laptop configuration
        school-laptop = mkNixOSConfig ./hosts/school-laptop/configuration.nix [ lanzaboote.nixosModules.lanzaboote ];
        
        # VM for development
        nixos-devbox = mkNixOSConfig ./hosts/nixos-devbox/configuration.nix [];

        # Define the auto-installation ISO configuration
        autoinstall = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs vars; };
          modules = [
            ./hosts/autoinstall/configuration.nix
            disko.nixosModules.disko
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ({ pkgs, ... }: {
              image = { fileName = "nix-autoinstall.iso"; };
              isoImage = {
                makeEfiBootable = true;
                makeUsbBootable = true;
              };
            })
          ];
        };
      };
    };
}
