{ lib, ... }:

{
  disko.devices.disk.main = {
    device = "/dev/vda";
    type = "disk";
    content = {
      type = "msdos";
      partitions = {
        root = {
          priority = 1;
          size = "100%";
          type = "83";
          bootable = true;
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
