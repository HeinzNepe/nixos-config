{ config, pkgs, lib, ... }:

{
    # Include the disko module for disk partitioning
    imports = [
    ./disko.nix
    ];

    # Boot configuration for systemd-boot (standard NixOS bootloader)
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Enable flakes and nix-command
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Enable disko
    environment.systemPackages = [ pkgs.disko ];
    disko.enableConfig = true;

    # Copy disko config to /etc for the installer
    environment.etc."disko.nix".source = ./disko.nix;

    # Auto-install user
    users.users.henrik = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$tsKkFmzTKdHpfz/S$84YR0GJWGYVk3rGeKPSdeX.YaFyZV8V7PUWQLzrZvoo0CAt2WwuxyjQwCLOBx.BRecJsoAxKU9w6wF04Z57FY.";  # Generate with: mkpasswd -m sha-512
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHlcSbSiViVlhO3v2jz7U0NYBi8hags7R0TCvhIFSlgA" # Portunus-Alfa
    ];
    };

    # Enable SSH for remote access during installation
    services.openssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;

    # Auto-install service
    systemd.services.autoinstall = {
      description = "Automatic NixOS installation";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      environment = {
        NIX_PATH = "nixpkgs=${pkgs.path}";
      };
      script = ''
        # Check if already installed
        if [ -f /mnt/etc/nixos/configuration.nix ]; then
          echo "System already installed, skipping..."
          exit 0
        fi

        echo "Starting automatic installation..."
        
        # Wipe the disk completely first
        echo "Wiping disk /dev/vda..."
        ${pkgs.util-linux}/bin/wipefs -af /dev/vda
        ${pkgs.gptfdisk}/bin/sgdisk --zap-all /dev/vda
        
        # Run disko to partition and format disk
        ${pkgs.disko}/bin/disko --mode disko /etc/disko.nix
        
        # Generate hardware configuration
        nixos-generate-config --root /mnt
        
        # Create a proper configuration.nix with flakes enabled
        cat > /mnt/etc/nixos/configuration.nix << 'EOF'
        { config, pkgs, ... }:
        {
          imports = [ ./hardware-configuration.nix ];
          
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          
          # Enable flakes
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          
          # Enable SSH
          services.openssh.enable = true;
          services.openssh.settings.PasswordAuthentication = false;
          
          # User configuration
          users.users.henrik = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            hashedPassword = "${config.users.users.henrik.hashedPassword}";
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHlcSbSiViVlhO3v2jz7U0NYBi8hags7R0TCvhIFSlgA"
            ];
          };
          
          system.stateVersion = "25.11";
        }
        EOF
        
        # Install the system
        nixos-install --no-root-password --root /mnt --no-channel-copy
        
        echo "Installation complete! System will reboot in 10 seconds..."
        sleep 10
        reboot
      '';
    };

    # Optional: auto-login or post-install hooks
    system.stateVersion = "25.11";
}
