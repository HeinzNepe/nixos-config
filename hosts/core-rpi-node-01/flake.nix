{
  description = "NixOS configuration for Raspberry Pi FR24 ADS-B feeder";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # nixos-hardware provides well-tested Raspberry Pi hardware modules
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.fr24-feeder = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # ── Hardware ─────────────────────────────────────────────────────────
        # Choose the line that matches your Pi model (uncomment one):
        nixos-hardware.nixosModules.raspberry-pi-4        # RPi 4 / 400 / CM4
        # nixos-hardware.nixosModules.raspberry-pi-3      # RPi 3B / 3B+
        # nixos-hardware.nixosModules.raspberry-pi-zero-2 # RPi Zero 2 W

        # ── SD card image builder ─────────────────────────────────────────────
        # Lets you produce a flashable .img with:
        #   nix build .#nixosConfigurations.fr24-feeder.config.system.build.sdImage
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

        # ── Main configuration ────────────────────────────────────────────────
        ./configuration.nix
      ];
    };
  };
}
