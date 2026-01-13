{ lib, ... }:
# Disk partitioning configuration for NixOS installer (disko module)
# This module defines the disk layout for the installer using the disko tool.
{
  disko.devices.disk.main = {
    device = "/dev/vda"; # Target disk device
    type = "disk";
    content = {
      type = "msdos"; # Partition table type
      partitions = {
        root = {
          priority = 1;
          size = "100%"; # Use the entire disk for root
          type = "83"; # Linux filesystem partition type
          bootable = true;
          content = {
            type = "filesystem";
            format = "ext4"; # Use ext4 filesystem
            mountpoint = "/"; # Mount as root
          };
        };
      };
    };
  };
}
