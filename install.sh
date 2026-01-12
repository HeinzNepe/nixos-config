#!/usr/bin/env bash

set -e -o pipefail

# Define available system types
SYSTEM_TYPES=("vm")

# Display menu and get user selection
echo -e "\033[1mSelect system type:\033[0m"
for i in "${!SYSTEM_TYPES[@]}"; do
  echo "$((i + 1)). ${SYSTEM_TYPES[$i]}"
done

read -p "Enter your choice (1-${#SYSTEM_TYPES[@]}): " choice

# Validate choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#SYSTEM_TYPES[@]}" ]; then
  echo "Error: Invalid selection"
  exit 1
fi

# Get selected type
SYSTYPE="${SYSTEM_TYPES[$((choice - 1))]}"
echo -e "\n\033[32mSelected: $SYSTYPE\033[0m\n"



if [ "$SYSTYPE" == "vm" ]; then
  # Define disk
  DISK="/dev/sda"
  DISK_BOOT_PARTITION="/dev/sda1"
  DISK_NIX_PARTITION="/dev/sda2"

  # Display warning and wait for confirmation to proceed
  echo "Linux selected"
  echo -e "\n\033[1;31m**Warning:** This script is irreversible and will prepare system for NixOS installation.\033[0m"
  read -p "Type 'yes' to continue or Ctrl+C to abort: " confirm
  if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
  fi

  # Clear screen before showing disk layout
  clear

  # Display disk layout
  echo -e "\n\033[1mDisk Layout:\033[0m"
  lsblk
  echo ""

  # Undo any previous changes if applicable
  echo -e "\n\033[1mUndoing any previous changes...\033[0m"
  set +e
  umount -R /mnt
  cryptsetup close cryptroot
  set -e
  echo -e "\033[32mPrevious changes undone.\033[0m"

  # Partitioning disk
  echo -e "\n\033[1mPartitioning disk...\033[0m"
  parted $DISK -- mklabel gpt
  parted $DISK -- mkpart ESP fat32 1MiB 1001MiB
  parted $DISK -- set 1 boot on
  parted $DISK -- mkpart Nix 1001MiB 100%
  echo -e "\033[32mDisk partitioned successfully.\033[0m"

  # Creating filesystems
  echo -e "\n\033[1mCreating filesystems...\033[0m"
  mkfs.fat -F32 -n boot $DISK_BOOT_PARTITION
  mkfs.ext4 -F -L nix -m 0 $DISK_NIX_PARTITION
  # Let mkfs catch its breath
  sleep 2
  echo -e "\033[32mFilesystems created successfully.\033[0m"

  # Mounting filesystems
  echo -e "\n\033[1mMounting filesystems...\033[0m"
  mount -t tmpfs -o mode=0755 none /mnt
  mkdir -pv /mnt/{boot,nix,etc/ssh,var/{lib,log}}
  mount /dev/disk/by-label/boot /mnt/boot
  mount /dev/disk/by-label/nix /mnt/nix
  mkdir -pv /mnt/nix/{initrd/{etc/ssh,var/{lib,log}}}
  chmod 0755 /mnt/nix
  echo -e "\033[32mFilesystems mounted successfully.\033[0m"

  # Completed
  echo -e "\n\033[1;32mAll steps completed successfully. NixOS is now ready to be installed.\033[0m\n"
  echo -e "To install NixOS configuration for hostname, run the following command:\n"
  echo -e "\033[1msudo nixos-install --no-root-passwd --root /mnt --flake github:heinznepe/nixos-config#hostname\033[0m\n"
fi