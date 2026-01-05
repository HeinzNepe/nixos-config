{ pkgs, ... }:
{
    # Allow the Cisco Packet Tracer package from the insecure binary cache
    nixpkgs.config.permittedInsecurePackages = [
                "ciscoPacketTracer8-8.2.2"
              ];

    # To ensure Packet Tracer works correctly, we need to add it to systemPackages
    environment.systemPackages = with pkgs; [
        ciscoPacketTracer8
    ];

    # Before rebuilding we need to manually add it to the nixcache
    # by running the following command:
    # nix-store --add-fixed sha256 CiscoPacketTracer_"version"_Ubuntu_64bit.deb
    #
    # e.g.
    # nix-store --add-fixed sha256 CiscoPacketTracer822_amd64_signed.deb
}