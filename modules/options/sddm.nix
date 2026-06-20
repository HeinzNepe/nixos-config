{ inputs, pkgs, system, ... }:

{
    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.theme = "breeze-dark";
}