{ ... }:

{
    # Enable and configure the OpenSSH server
    services.openssh = {
        # Enable the SSH server
        enable = true;
        # Address and port to listen on
        listenAddresses = [ {
            addr = "100.109.243.16";
            port = 22;
        } ]; # Listen on all interfaces
        # SSH server settings
        settings = {
            # Sets PasswordAuthentication to "no" to disable password-based authentication
            PasswordAuthentication = false;
            # Usernames allowed to connect via SSH
            #AllowUsers = ["root" "henrik" "heinz"]; 
            AllowUsers = ["henrik"]; 
            # Disable root login via SSH using password. This forces key-based authentication for root.
            PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
        };
    };

    # Ensure the SSH service starts after the network is online to avoid issues with network-dependent SSH configurations.
    systemd.services.sshd = {
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
    };

    # Allow members of wheel to sudo without a password (not thaaaat secure but convenient for e.g. VMs)
    security.sudo.wheelNeedsPassword = false;
}