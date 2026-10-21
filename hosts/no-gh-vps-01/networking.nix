{ ... }:

{
    # Static network configuration for the VPS. This is included in the main configuration.nix file.
    networking = {
        #useDHCP = true;

        
        # Set the configuraion on the interface
        interfaces.ens18 = { 
            # IPv4 address
            ipv4.addresses = [{
                # VPS public IPv4
                address = "193.243.189.188";
                prefixLength = 24; # Gigahost gives a /24 subnet
            }];

            # IPv6 address
            ipv6.addresses = [{
                # VPS public IPv6
                address = "2a03:94e3:ffff:193:243:189::188";
                prefixLength = 118;
            }];
        
       };
        

        # Hetzner's default gateway for this subnet
        defaultGateway = {
            address = "193.243.189.1";
            interface = "ens18";
        };

        # Hetzners link-local default gateway for IPv6
        defaultGateway6 = {
            address = "2a03:94e3:ffff:193:243:189::1";
            interface = "ens18";
        }; 
        

        # DNS servers
        #nameservers = [ "185.12.64.2" "185.12.64.1" "2a01:4ff:ff00::add:2" "2a01:4ff:ff00::add:1" ]; # Hetzner
        nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ]; # Cloudflare
        #search = [ ]; # Search domains, not relevant for a VPS with a single hostname

        # Enable the firewall. Inbound traffic is dropped by default unless explicitly allowed.
        firewall.enable = true;
        firewall.interfaces.ens18 = {
            allowedTCPPorts = [ 22 80 443 ]; # SSH, HTTP, HTTPS
            allowedUDPPorts = [ 51820 21820 ]; # Pangolin Wireguard and NEWT
        };
        # Or disable the firewall altogether.
        # firewall.enable = false;
    };

    # Enable networking with DHCP for all non-configured links
    #networking.networkmanager.enable = true;


    # Enable Fail2Ban to protect against brute-force attacks on SSH
    services.fail2ban = {
        enable = true;
        ignoreIP = [ "core.ip.topheinz.com" ];
    };
}
