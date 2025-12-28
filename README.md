# My NixOS config
(more coming later)

## The repo
This repository is a repo containing all of my nixOS configurations.

### Cloning the repo
Clone this repo,
```
git clone https://github.com/HeinzNepe/nixos-config.git
```

### Updating the git remote
If you want to commit stuff from a device using SSH for auth, you have to update the repository remote with the following command:
```
git remote set-url origin git@github.com:HeinzNepe/nixos-config.git
```

## The flake
Use the following command to initiate the configuration using a nix flake
```
sudo nixos-rebuild switch --flake .#device
```

Where \#device is any of the following devices: 
- laptop
- desktop
- wsl

### Updating the flake
Updating the flake is done with
```
sudo nix flake update
```

### Garbage collection
To remove un-needed packages from the local nix store, you can use
```
sudo nix-collect-garbage -d
```

## Userful setup steps

### Enable nix experimental features
To use nix flakes, you need to enable the experimental features in nix.
Add the following lines to `/etc/nix/configuration.nix`:
```
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### Start nix shell with git
To start a nix shell with git installed, use the following command:
```
nix shell nixpkgs#git
```

## Secure boot

This system uses **Lanzaboote** to provide Secure Boot support on NixOS. Lanzaboote replaces systemd‑boot and handles signing the bootloader and kernel so the firmware can verify them at boot.

### Generating Secure Boot keys

Before enabling Secure Boot, generate a fresh key set:

```bash
nix-shell -p sbctl
```

Then run:

```bash
sudo sbctl create-keys --path /etc/secureboot
```

This creates the Platform Key (PK), Key Exchange Key (KEK), and signature database (db) used by your firmware.

Move them to the /etc/secureboot directory so Lanzaboote can find them.
```bash
sudo mv /var/lib/sbctl/ /etc/secureboot/
```

### Enrolling Secure Boot keys in firmware
Enroll the keys into your system firmware:

```bash
sudo sbctl enroll-keys --microsoft
```
This will guide you through enrolling the keys, including adding Microsoft's key for compatibility. Follow the prompts to complete the process.

### Enabling Secure Boot in NixOS

Secure Boot is configured through the `secureboot.nix` module. It enables Lanzaboote and points NixOS to the key directory:

```nix
boot.lanzaboote.enable = true;
boot.lanzaboote.pkiBundle = "/etc/secureboot";
boot.loader.efi.canTouchEfiVariables = true;
boot.loader.systemd-boot.enable = false;
```

### Rebuild your system

After generating keys and enabling the module:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

### Verifying Secure Boot
After rebuilding use sbctl to verify Secure Boot status:

```bash
sudo sbctl status
```