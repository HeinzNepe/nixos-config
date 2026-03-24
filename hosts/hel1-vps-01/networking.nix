{ ... }:

{
    # IPv4 address
    networking.interfaces.enp1s0.ipv4.addresses = [
    {
        # VPS public IPv4
        address = "46.62.198.145";
        prefixLength = 32;
    }
    ];

    # Hetzner's default gateway for this subnet
    networking.defaultGateway = "172.31.1.1";

    # IPv6 address
    networking.interfaces.enp1s0.ipv6.addresses = [
    {
        # VPS public IPv6
        address = "2a01:4f9:c013:7b50::1";
        prefixLength = 64;
    }
    ];
    # Hetzners link-local default gateway for IPv6
    networking.defaultGateway6 = "fe80::1";

    # DNS servers (Hetzner's public DNS)
    networking.nameservers = [ "185.12.64.2" "185.12.64.1" "2a01:4ff:ff00::add:2" "2a01:4ff:ff00::add:1" ];
    #networking.nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ]; # Cloudflare
    #networking.search = [ ];

    # Enable and open ports in the firewall.
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [ 22 80 443 ]; # SSH, HTTP, HTTPS
    networking.firewall.allowedUDPPorts = [ 51820 21820 ]; # Pangolin Wireguard and NEWT 
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;
}
