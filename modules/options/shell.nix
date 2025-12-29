{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        # Bash shell for command line interface
        bash

        # Core utilities is a collection of basic file, shell and text manipulation utilities
        coreutils
        
        # Gnupg for encryption and signing data and communications
        gnupg

        # Openssh for secure shell access
        openssh

        # Wget for downloading files from the web
        wget

        # Curl for transferring data with URLs
        curl

        # Tmux for terminal multiplexing
        tmux
    ];

        # TMUX system-wide configuration
        # Set status bar to show hostname, date and time (no timezone)
        environment.etc."tmux.conf".text = ''
            set -g status-interval 1
            set -g status-right "#(date '+%Y-%m-%d') - #(date '+%H:%M:%S')"
        '';


}
