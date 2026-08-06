{ config, pkgs, ... }:

{
    # This is for enabling the guest agent on virtual machines hosted on nixos, not enabling it on the host.
    #virtualisation.qemu.guestAgent.enable = true;

    # This enables the guest agent on the nix host
    services.qemuGuest.enable = true;

}
