{ pkgs, ... }:
{
    # Cisco Packet Tracer 9 (unfree, allowed via nixpkgs.config.allowUnfree in the host config)
    environment.systemPackages = with pkgs; [
        ciscoPacketTracer9
    ];

    # Before rebuilding we need to manually add the .deb to the nix store
    # (deb file available from OneDrive or Cisco Networking Academy)
    # by running the following command:
    # nix-store --add-fixed sha256 CiscoPacketTracer_"version"_Ubuntu_64bit.deb
    #
    # e.g.
    # nix-store --add-fixed sha256 CiscoPacketTracer_901_Ubuntu_64bit.deb
}