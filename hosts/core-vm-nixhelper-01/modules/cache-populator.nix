{ config, ... }:

{
    systemd.services.nix-cache-refresh = {
    description = "Build and cache packages on flake update";
    after = [ "network.target" ];
    serviceConfig = {
        Type = "oneshot";
        User = "root";
    };
    script = ''
        set -e
        cd /home/henrik/GitHub/nixos-config  # or wherever you keep a clone of your flake repo

        git fetch origin
        LOCAL=$(git rev-parse HEAD)
        REMOTE=$(git rev-parse origin/main)

        if [ "$LOCAL" = "$REMOTE" ]; then
        echo "No changes, skipping build."
        exit 0
        fi

        git pull origin main

        nix build .#nixosConfigurations.desktop.config.system.build.toplevel \
                .#nixosConfigurations.school-laptop.config.system.build.toplevel \
                --no-link

        echo "Build complete, cache populated."
    '';
    };

    # Check every 5 minutes
    systemd.timers.nix-cache-refresh = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "5min";
    };
    };
}