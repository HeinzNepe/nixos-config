{ ... }:

{
    # Enable and configure the OpenSSH server
    services.openssh = {
        # Enable the SSH server
        enable = true;
        # Default SSH port
        ports = [ 22 ];
        # SSH server settings
        settings = {
            # Sets PasswordAuthentication to "no" to disable password-based authentication
            PasswordAuthentication = false;
            # Usernames allowed to connect via SSH
            AllowUsers = ["henrik" "heinz"]; 
            # Disable root login via SSH using password. This forces key-based authentication for root.
            PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
        };
    };

    # Allow members of wheel to sudo without a password (not thaaaat secure but convenient for e.g. VMs)
    security.sudo.wheelNeedsPassword = false;
}