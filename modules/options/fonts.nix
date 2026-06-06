{ config, lib, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    fontconfig.enable = true;

    packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        roboto

        # Base Noto (includes Khmer, Thai, etc.)
        noto-fonts
        noto-fonts-color-emoji

        # CJK support
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        dejavu_fonts
        liberation_ttf
    ];
  };

  environment.sessionVariables = {
    FONTCONFIG_PATH = "${pkgs.fontconfig}/etc/fonts";
  };
}
