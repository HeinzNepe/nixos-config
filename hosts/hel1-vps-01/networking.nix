{ ... }:

{
    networking = {
        # IPv4 address
        interfaces.enp1s0 = { 
            ipv4.addresses = {
                # VPS public IPv4
                address = "46.62.198.145";
                prefixLength = 32;
            };

            # IPv6 address
            ipv6.addresses = {
                # VPS public IPv6
                address = "2a01:4f9:c013:7b50::1";
                prefixLength = 64;
            };
        
        };
        

        # Hetzner's default gateway for this subnet
        defaultGateway = {
            address = "172.31.1.1";
            interface = enp1s0; # Required since the gateway is not in the same subnet as the VPS's IP
        };

        # Hetzners link-local default gateway for IPv6
        defaultGateway6 = {
            address = "fe80::1";
            interface = enp1s0; # Required since the gateway is not in the same subnet as the VPS's IP
        };

        # DNS servers
        nameservers = [ "185.12.64.2" "185.12.64.1" "2a01:4ff:ff00::add:2" "2a01:4ff:ff00::add:1" ]; # Hetzner
        #nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ]; # Cloudflare
        #search = [ ]; # Search domains, not relevant for a VPS with a single hostname

        # Enable and open ports in the firewall.
        firewall.enable = true;
        firewall.allowedTCPPorts = [ 22 80 443 ]; # SSH, HTTP, HTTPS
        firewall.allowedUDPPorts = [ 51820 21820 ]; # Pangolin Wireguard and NEWT 
        # Or disable the firewall altogether.
        # firewall.enable = false;
    };
}
