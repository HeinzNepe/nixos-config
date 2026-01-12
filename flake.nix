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

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, nixpkgs-stable, lanzaboote, home-manager, plasma-manager, disko, ... }@inputs:
    let
      vars = import ./vars.nix;
      mkNixOSConfig = path: extraModules: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs vars; };
        modules = [ path ] ++ extraModules;
      };
    in {
      nixosConfigurations = {
        # Define NixOS configurations for different hosts
        
        # Laptop configuration
        laptop = mkNixOSConfig ./hosts/laptop/configuration.nix [];
        
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
