{ pkgs, ... }:
{
    # Packages
    environment.systemPackages = with pkgs; [
        javaPackages.compiler.openjdk25
        maven
    ];
}