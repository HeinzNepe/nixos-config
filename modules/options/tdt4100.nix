{ pkgs, ... }:
{
    # Enable nix-ld for better Nix package management
    #programs.nix-ld.enable = true;

    # Packages
    environment.systemPackages = with pkgs; [
        # Eclipse Temurin, prebuilt OpenJDK binarys
        #javaPackages.compiler.temurin-bin.jdk-25

        # X11 libraries required for Java GUI applications
        #xorg.libX11
        #xorg.libXcursor
        #xorg.libXrandr
        #xorg.libXi
        #xorg.libXext
        #xorg.libXtst
        #xorg.libXxf86vm
        #xorg.libXrender

        # OpenJDK 25
        #javaPackages.compiler.openjdk25
        # Maven for Java project management
        #maven
        # Additional dependencies
        #libxxf86vm
        #glib
    ];
}