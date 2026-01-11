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


  # Define the outputs
  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, plasma-manager, lanzaboote, disko, ... }@inputs:
    let system = "x86_64-linux";
        pkgs-stable = import nixpkgs-stable { inherit system; config = { allowUnfree = true; }; };
    in {
      
      nixosConfigurations = {

        # Define the laptop state
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system inputs pkgs-stable; };
          modules = [ ./hosts/laptop/configuration.nix ];
        };

        # Define the desktop state
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system inputs pkgs-stable; };
          modules = [ 
            ./hosts/desktop/configuration.nix
            # To enable Secure Boot for this host, add:
            lanzaboote.nixosModules.lanzaboote 
          ];
          
        };

        # Define the school laptop state
        school-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system inputs pkgs-stable; };
          modules = [
            ./hosts/school-laptop/configuration.nix
            # To enable Secure Boot for this host, add:
            lanzaboote.nixosModules.lanzaboote
          ];
        };

	      # Define the devbox state
        nixos-devbox = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system inputs pkgs-stable; };
          modules = [ 
            ./hosts/nixos-devbox/configuration.nix
            # To enable Secure Boot for this host, add:
            #lanzaboote.nixosModules.lanzaboote
          ];
        };

        # Define the autoinstall state
        autoinstall = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system inputs pkgs-stable; };
          modules = [ 
            ./hosts/autoinstall/configuration.nix
            disko.nixosModules.disko
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ({ pkgs, ... }: {
              image = {
                fileName = "nix-autoinstall.iso";
              };
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
