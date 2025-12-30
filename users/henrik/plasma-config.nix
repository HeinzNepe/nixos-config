{ config, pkgs, ... }:

{
  # Enable KDE Plasma with a dark theme
  programs.plasma = {
    enable = true;
    workspace = {
      colorScheme = "BreezeDark";
      lookAndFeel = "org.kde.breezedark.desktop";
      theme = "BreezeDark";
      iconTheme = "breeze-dark";
    };
  };
}