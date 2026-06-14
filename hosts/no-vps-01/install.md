# NixOS VPS Installation

## 1. Download the Installer

Explicitly download the x86_64 version:

```bash
wget -v https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz
```

## 2. Sanity Check & Extract

```bash
# Verify the file before extracting
ls -lh nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz
file nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz

# Extract
tar -xf nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz

# Verify the binary architecture (should say: ELF 64-bit LSB executable, x86-64, ...)
file ./kexec/ip
```

## 3. Boot into the Installer

```bash
sudo ./kexec/run
```

You are now in the NixOS installer.

---

## 4. Partition the Disk

```bash
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary 1MiB -1MiB
parted /dev/sda -- set 1 boot on
```

## 5. Format the Partition

```bash
mkfs.ext4 -L nixos /dev/sda1
```

## 6. Mount

```bash
mount /dev/disk/by-label/nixos /mnt
```

## 7. Generate Config

```bash
nixos-generate-config --root /mnt
```

## 8. Update Config in GitHub

Push your flake changes to GitHub before proceeding.

## 9. Install from GitHub

```bash
nixos-install --flake github:heinznepe/nixos-config#no-vps-01
```