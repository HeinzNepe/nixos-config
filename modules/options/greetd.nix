{ inputs, pkgs, system, ... }: let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  #hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
  #plasma-session = "${pkgs.kdePackages.plasma-workspace}/share/wayland-sessions";
  startplasma = "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-wayland";
in {
  # Enable the KDE Plasma Desktop Environment.
  # Enable Plasma 6
  services.desktopManager.plasma6.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  #services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.theme = "breeze-dark";

services.greetd = {
    enable = true;
    settings = {
      default_session = {
        #command = "${tuigreet} --time --remember --remember-session --sessions ${hyprland-session}";
        #command = "${tuigreet} --time --remember --remember-session --sessions ${plasma-session}";
        command = "${tuigreet} --time --remember --remember-session --cmd ${startplasma}";
        user = "greeter";
      };
    };
  };

  # this is a life saver.
  # literally no documentation about this anywhere.
  # might be good to write about this...
  # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmonad_how/
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}