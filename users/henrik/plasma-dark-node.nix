{ config, pkgs, ... }:

{
  home.file = {
    ".config/kdeglobals".text = ''
      [General]
      ColorScheme=BreezeDark

      [Icons]
      Theme=breeze-dark
    '';
    ".config/plasmarc".text = ''
      [Theme]
      name=BreezeDark
    '';
    ".config/plasma-org.kde.plasma.desktop-appletsrc".text = ''
      [Containments][1][General]
      theme=BreezeDark
    '';
  };
}