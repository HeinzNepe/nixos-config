{ lib, ... }:

{
  disko.devices.disk.main = {
    device = "/dev/vda"; # Proxmox usually uses /dev/vda. Adjust if your VM uses /dev/sda or NVMe
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1GiB"; # ← updated from 512M to 1GiB
          type = "EF00"; # EFI System Partition
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%"; # uses the rest of the disk
          type = "8300"; # Linux filesystem
          content = {
            type = "filesystem";
            format = "ext4"; # or btrfs/zfs if you prefer
            mountpoint = "/";
          };
        };
      };
    };
  };
}
