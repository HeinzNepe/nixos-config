{ ... }:

{
    # Enable the Tailscale service:
    services.tailscale = {
        enable = true;
        useRoutingFeatures = "client"; # Enable client features only
    };

    # Tell the firewall to implicitly trust packets routed over Tailscale:
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
}