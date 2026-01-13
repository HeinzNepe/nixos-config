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
- school-laptop
- nixos-devbox

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

### Checking the flake for syntax errors
To check the flake for syntax errors, you can use
```
nix flake check
```

## Using NH

Using nh you can simplify a lot of the commands you need to run for nix flakes.

### Rebuilding
To rebuild the system using nh, you can use
```
nh os switch . -H hostname -a
```

### Updating the flake
To update the flake using nh, you can use
```
nh os switch . -H hostname -a -u
```

### Garbage collection
To run garbage collection using nh, you can use
```
nh clean all
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
sudo sbctl create-keys
```

This creates the Platform Key (PK), Key Exchange Key (KEK), and signature database (db) used by your firmware in the file path /var/lib/sbctl/

I then move them to the /etc/secureboot directory so Lanzaboote can find them. (because I've set /etc/secureboot as the key location)
```bash
sudo mv /var/lib/sbctl/ /etc/secureboot/
```

### Enrolling Secure Boot keys in firmware
Enroll the keys into your system firmware:

```bash
sudo sbctl enroll-keys --microsoft
```
This will guide you through enrolling the keys. Follow the prompts to complete the process.
Usually, it will tell you to put the secure boot in "Setup Mode" which is either set in the Bios, or achieved by deleting all Secure Boot keys

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

## Custom ISO image
This flake contains a custom ISO image, that is imagined primarily for setting up VMs on proxmox. The approximate task list of the ISO is the following:

1. Format the disk (1 GB ESP partition, rest for NixOS)
2. Install NixOS
3. Reboot

After these steps are done, it's possible to SSH in with the defined user (henrik) and SSH key (Homelab Key).

### Building the ISO
To build the ISO file, run the following command in the nixos-config directory:
```
nix build .#nixosConfigurations.autoinstall.config.system.build.isoImage
```

The resulting ISO will be located at `result/iso/nix-autoinstall.iso`

### Retrieve hardware configuration
Hardware generation is generated with the following command

```
nixos-generate-config --show-hardware-config
```