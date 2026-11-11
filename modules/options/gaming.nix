{ inputs, pkgs, pkgs-stable, ... }:

{
  # Add gaming related packages to system environment
  environment.systemPackages = [
    # From stable channel
    pkgs-stable.modrinth-app

    # From unstable channel
    pkgs.tetrio-desktop

    # Add Java JDK for minecraft
    # Available through symlink: /run/current-system/sw/bin/java
    #pkgs.jdk8 
    #pkgs.jdk17 
    #pkgs.jdk21
    pkgs.jdk25
  ];

  

  # Steam
  # Note: GeoGuessr Steam Edition requires the launch option
  #   PROTON_USE_WINED3D=1 %command%
  # and runs on Proton 10.0-4 (verified working setup).
  programs.steam = {
    enable = true;
    fontPackages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      # GeoGuessr (Electron/Chromium) falls back to these exact family
      # names for Ethiopic and Khmer script; without them place names in
      # Ethiopia and Cambodia render as squares.
      sil-abyssinica
      khmeros
    ];
  };

}
