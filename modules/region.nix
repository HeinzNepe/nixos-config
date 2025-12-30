{ config, pkgs, ...}:

{
  # Set time zone
  time.timeZone = "Europe/Oslo";

  # Set the hardware clock to local time
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties. 
  i18n.defaultLocale = "en_GB.UTF-8";

  # Configure console keymap
  console.keyMap = "no";

}
