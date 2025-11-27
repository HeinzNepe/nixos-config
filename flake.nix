{
  description = "Henrik's flake";

  # Define the inputs used for the flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };


  # Define the outputs
  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let system = "x86_64-linux";
    in {
      nixosConfigurations = {
        # Define the laptop state
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system inputs; };
          modules = [ ./hosts/laptop/configuration.nix ];
        };
        # Define the desktop state
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system inputs; };
          modules = [ ./hosts/desktop/configuration.nix ];
        };
      };
    };
}
