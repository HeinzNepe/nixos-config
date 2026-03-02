{ config, pkgs, ... }:

# Build server configuration
# This module configures a machine to act as a remote Nix build server for other machines
{
  # Create a dedicated builder user
  users.users.remotebuild = {
    isSystemUser = true;
    group = "remotebuild";
    #home = "/var/lib/nixbuilder";
    #createHome = true;
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmLe1jJP+wP7xq5AeOjxi+ZibXyorKIs1ZxxpHxYJKY nixos-builder"
    ];
  };

  users.groups.remotebuild = {};

  # Enable SSH server for remote builds
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      AllowUsers = [ "remotebuild" "henrik" "heinz" ]; # Allow SSH access for builder and admins
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Configure Nix daemon for remote builds
  nix.settings = {
    # Allow remotebuild and root to use SSH for remote builds
    trusted-users = [ "root" "remotebuild" "@wheel" ];
    
    # Optimize build settings
    max-jobs = "auto";
    cores = 0; # Use all available cores
    
    # Enable experimental features if needed
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Open SSH port for remote builders
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Increase system limits for building
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];

  # Install useful build tools
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
  ];
}
