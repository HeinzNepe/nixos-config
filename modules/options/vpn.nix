{ config, lib, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        # Install wireguard tools
        wireguard-tools

        # Install proton-vpn gui client
        protonvpn-gui
    ];
}