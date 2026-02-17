{ inputs, pkgs, system, ... }:

{
  # Enable the X11 windowing system.
  # You can disable this if youre only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  #services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.theme = "breeze-dark";
  
  # Enable Plasma 6
  services.desktopManager.plasma6.enable = true;

  # Enable gdm display manager
  services.displayManager.gdm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "no";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

}
