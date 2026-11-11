{ inputs, pkgs, pkgs-stable, ... }:

{
    # Add gaming related packages to system environment
    environment.systemPackages = [
        # From unstable channel
        pkgs.tetrio-desktop
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

    # Enable hardware accelerated graphics (Do i need this?)
    hardware.graphics = {
    enable = true;
    enable32Bit = true;
    };

}
