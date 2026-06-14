{ ... }:

{
    # Enable the Tailscale service:
    services.tailscale.enable = true;

    # Tell the firewall to implicitly trust packets routed over Tailscale:
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
}