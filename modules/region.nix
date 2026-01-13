{ config, pkgs, ...}:
# Regional and localization settings for NixOS
# This module sets timezone, locale, and keymap for the system.
{
  # Set the system time zone
  time.timeZone = "Europe/Oslo";

  # Set the hardware clock to local time (important for dual-boot with Windows)
  time.hardwareClockInLocalTime = true;

  # Set the default locale for internationalization
  i18n.defaultLocale = "en_GB.UTF-8";

  # Set the console keymap (keyboard layout)
  console.keyMap = "no";
}
