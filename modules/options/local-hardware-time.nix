{ config, lib, ... }:
{
  # Set the hardware clock to local time instead of UTC.
  # This is necessary for dual-booting with Windows, which expects the hardware clock to be local time.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  time.hardwareClockInLocalTime = true;
}
