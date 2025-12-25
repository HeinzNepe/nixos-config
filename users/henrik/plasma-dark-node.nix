{ config, pkgs, ... }:

{
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