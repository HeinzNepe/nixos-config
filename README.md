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

## SOPS secrets

This repo uses sops-nix and derives Age keys from each host SSH key. The shared SOPS configuration lives in [modules/sops.nix](modules/sops.nix), and the key groups are defined in [.sops.yaml](.sops.yaml).

### Device layout and key groups

- Admin devices: school-laptop, nixos-devbox, desktop
- Non-admin devices: laptop, core-vm-gitea-01

Secrets are organized as:
- Shared admin secrets: [secrets/common.yaml](secrets/common.yaml)
- Per-host secrets: [secrets/hosts/](secrets/hosts/)

WSL and autoinstall are currently excluded.

### Adding a new device

1. Get the host SSH public key on the new device:
```
cat /etc/ssh/ssh_host_ed25519_key.pub
```

If the host key does not exist yet, generate it first:
```
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
```

2. Convert the SSH key to an Age recipient:
```
ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
```

3. Add the new Age recipient to [.sops.yaml](.sops.yaml):
  - Add it under `keys:` with a clear anchor name.
  - If it is an admin device, add it to the `admin_group` anchor.
  - If it is a non-admin device, add a host-specific rule that includes `admin_group` plus the device key.

4. Create a host secrets file for the device in [secrets/hosts/](secrets/hosts/).

### Setting up age keys locally

**Important:** Age keys should **never** be committed to the repository. Instead, they are derived locally from each host's SSH key.

The NixOS configuration automatically handles this through [modules/sops.nix](modules/sops.nix), which configures SOPS to use the SSH host key (`/etc/ssh/ssh_host_ed25519_key`) for age encryption/decryption. After rebuilding with `sudo nixos-rebuild switch --flake .#<hostname>`, SOPS will work automatically.

If you need to edit secrets on a system before the first NixOS rebuild, manually generate the age key:

```bash
bash setup-sops-age.sh
```

Or manually:

```bash
mkdir -p ~/.config/sops/age
sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > ~/.config/sops/age/keys.txt
```

Ensure `.config/sops/age/keys.txt` is in your `.gitignore` so it doesn't get committed.

### Creating or editing secrets

Create or edit a shared admin secret:
```
sops secrets/common.yaml
```

Create or edit a host secret:
```
sops secrets/hosts/<hostname>.yaml
```

### Using secrets in NixOS

Define secrets in host config and reference them from sops-nix. Example patterns:
- Add sops file path(s) to `sops.secrets` in the host configuration.
- Read the decrypted secret from the path provided by sops-nix.

If you add a new secrets file or update key groups, rebuild the host:
```
sudo nixos-rebuild switch --flake .#<hostname>
```

### Manual builder key

The builder SSH key used by [modules/homelab/nix-substitutors.nix](modules/homelab/nix-substitutors.nix) can also be stored manually on the machine at `/var/lib/nix/builder-ssh-key`.

If that file exists, it is copied to `/etc/nix/builder-ssh-key` at boot and takes precedence over the SOPS secret. A quick way to install it is:

```bash
sudo install -d -m 700 /var/lib/nix
sudo install -m 600 /dev/stdin /var/lib/nix/builder-ssh-key
```

Then paste the private key contents and finish with `Ctrl-D`.

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

## Using hyprland
To use hyprland, the section containing the monitor configuration must be added. This is stored in the configuration.nix file of each respective host, as it is individual.

To find the name of the display, run the following command
```
kscreen-doctor -o
```

The output here, will contain a line something like this:
`Output: 1 eDP-1 e8a4ce12-6b2f-4e83-bb12-100234ace57f`
Where `eDP-1` is the display name,

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