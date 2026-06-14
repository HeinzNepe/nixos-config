{ ... }:

{
    # Enable the Tailscale service:
    services.tailscale = {
        enable = true;
        useRoutingFeatures = "both"; # Enable subnet routing and exit nodes
    };

    # Tell the firewall to implicitly trust packets routed over Tailscale:
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
}