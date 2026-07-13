{
  description = "Henrik's flake";

  # Define the inputs used for the flake
  inputs = {
    # Add nixpkgs input under the unstable channel
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Add nixpkgs-stable input for stable packages
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    # Add nixos-hardware for hardware-specific modules, especially useful for Raspberry Pi configurations
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    # Nix minecraft for managing Minecraft server configurations with Nix
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    # Disko for disk management and auto-installation support
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Sops-nix for managing secrets in NixOS configurations
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Define the NixOS configurations for different hosts
  # Each host has its own configuration.nix file that imports common modules and defines host-specific settings
  outputs = { self, nixpkgs, nixpkgs-stable, lanzaboote, nix-minecraft, home-manager, plasma-manager, disko, sops-nix, nixos-hardware, ... }@inputs:
    let
      # Import the variables from vars.nix
      vars = import ./vars.nix;

      # Define a helper function to create NixOS configurations for each host
      # NOTE: system must be explicit for correctness
      mkNixOSConfig = system: path: extraModules:
        let
          pkgs-stable-import = import nixpkgs-stable {
            inherit system;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;

          # Pass inputs, vars, AND pkgs-stable to all modules
          specialArgs = {
            inherit inputs vars;
            pkgs-stable = pkgs-stable-import;
          };

          


          # Define modules to be included for all hosts, and append any extra modules specific to the host
          modules = [
            path
            sops-nix.nixosModules.sops
            
            # Allow unfree packages
            {
              nixpkgs.config.allowUnfree = true;
            }

            # Inject pkgs-stable into module args
            {
              _module.args.pkgs-stable = pkgs-stable-import;
            }
          ] ++ extraModules;
        };

    in {
      nixosConfigurations = {
        # VPS configuration
        hel1-vps-01 = mkNixOSConfig "x86_64-linux" ./hosts/hel1-vps-01/configuration.nix [];

        no-vps-01 = mkNixOSConfig "x86_64-linux" ./hosts/no-vps-01/configuration.nix [
          disko.nixosModules.disko
        ];

        # Homelab configuration
        core-vm-gitea-01 = mkNixOSConfig "x86_64-linux" ./hosts/core-vm-gitea-01/configuration.nix [];

        core-vm-minecraft-01 = mkNixOSConfig "x86_64-linux" ./hosts/core-vm-minecraft-01/configuration.nix [
          # Needed for the Minecraft server configuration
          nix-minecraft.nixosModules.minecraft-servers
          { nixpkgs.overlays = [ nix-minecraft.overlay ]; }
        ];

        core-vm-nixhelper-01 = mkNixOSConfig "x86_64-linux" ./hosts/core-vm-nixhelper-01/configuration.nix [];
        core-vm-services-01 = mkNixOSConfig "x86_64-linux" ./hosts/core-vm-services-01/configuration.nix [];

        #core-rpi-node-01 = nixpkgs.lib.nixosSystem {
        #  system = "aarch64-linux";
        #  specialArgs = { inherit inputs vars; };
        #  modules = [
        #    ./hosts/core-rpi-node-01/configuration.nix
        #    sops-nix.nixosModules.sops
        #    nixos-hardware.nixosModules.raspberry-pi-4
        #    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        #  ];
        #};

        # Jukebox laptop configuration
        jukebox = mkNixOSConfig "x86_64-linux" ./hosts/jukebox/configuration.nix [];

        # Desktop configuration
        desktop = mkNixOSConfig "x86_64-linux" ./hosts/desktop/configuration.nix [
          lanzaboote.nixosModules.lanzaboote
        ];

        # School laptop configuration
        school-laptop = mkNixOSConfig "x86_64-linux" ./hosts/school-laptop/configuration.nix [
          lanzaboote.nixosModules.lanzaboote
        ];

        # VM for development
        nixos-devbox = mkNixOSConfig "x86_64-linux" ./hosts/nixos-devbox/configuration.nix [
          #nix-minecraft.nixosModules.minecraft-servers
          #{ nixpkgs.overlays = [ nix-minecraft.overlay ]; }
        ];

        # Define the auto-installation ISO configuration
        autoinstall = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs vars; };
          modules = [
            ./hosts/autoinstall/configuration.nix
            disko.nixosModules.disko
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

            # ISO image settings
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
