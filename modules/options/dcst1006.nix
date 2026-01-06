{ pkgs, ... }:
{
    # Packages
    environment.systemPackages = with pkgs; [
        # Putty
        putty
    ];
}
