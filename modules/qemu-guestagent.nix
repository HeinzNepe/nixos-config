{ config, pkgs, ... }:

{
    virtualisation.qemu.guestAgent.enable = true;
}
