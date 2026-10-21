# NixOS VPS Installation

## 1. Partition the Disk

```bash
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary 1MiB -1MiB
parted /dev/sda -- set 1 boot on
```

## 2. Format the Partition

```bash
mkfs.ext4 -L nixos /dev/sda1
```

## 3. Mount

```bash
mount /dev/disk/by-label/nixos /mnt
```

## 4. Generate Config

```bash
nixos-generate-config --root /mnt
```

## 5. Update Config in GitHub

Push your flake changes to GitHub before proceeding.

## 6. Install from GitHub

```bash
nixos-install --flake github:heinznepe/nixos-config#no-gh-vps-01
```