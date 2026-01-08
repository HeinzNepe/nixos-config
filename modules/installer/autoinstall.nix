{ config, pkgs, lib, ... }:

{
    # Include the disko module for disk partitioning
    imports = [
    ./disko.nix
    ];

    # Enable disko
    environment.systemPackages = [ pkgs.disko ];
    disko.enableConfig = true;

    # Auto-install user
    users.users.henrik = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHlcSbSiViVlhO3v2jz7U0NYBi8hags7R0TCvhIFSlgA" # Portunus-Alfa
    ];
    };

    # Enable SSH for remote access during installation
    services.openssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;

    # Optional: auto-login or post-install hooks
    system.stateVersion = "25.11";
}
