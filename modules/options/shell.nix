{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        # Bash shell for command line interface
        bash

        # Zsh shell for enhanced experience
        zsh

        # Kitty terminal emulator
        kitty

        # Starship prompt
        starship

        # Fastfetch for system information display
        fastfetch

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

        # Autocompletion for bash
        bash-completion

        # Nixos anywhere for managing NixOS systems remotely
        nixos-anywhere

        # Autocompletion and suggestions for zsh
        zsh-completions
        zsh-autosuggestions
    ];

    # TMUX system-wide configuration
    # Set status bar to show hostname, date and time (no timezone)
    environment.etc."tmux.conf".text = ''
            set -g status-interval 1
            set -g status-right "#(date '+%Y-%m-%d') - #(date '+%H:%M:%S')"
    '';


    # Enable zsh and configure plugins for suggestions and completions
    programs.zsh = {
        enable = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = true;
        ohMyZsh = {
            enable = true;
            plugins = [ "git" ];
        };
    };


    # Set zsh as default shell for new users (system-wide)
    users.defaultUserShell = pkgs.zsh;

    # Configure starship prompt for all users
            programs.starship = {
                    enable = true;
                    settings = {
                        "$schema" = "https://starship.rs/config-schema.json";
                        format = "[░▒▓](#a3aed2)[  ](bg:#a3aed2 fg:#090c0c)[](bg:#769ff0 fg:#a3aed2)$directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$nodejs$rust$golang$php[](fg:#212736 bg:#1d2230)$time[ ](fg:#1d2230)\n$character";
                        directory = {
                            style = "fg:#e3e5e5 bg:#769ff0";
                            format = "[ $path ]($style)";
                            truncation_length = 3;
                            truncation_symbol = "…/";
                            substitutions = {
                                "Documents" = "󰈙 ";
                                "Downloads" = " ";
                                "Music" = " ";
                                "Pictures" = " ";
                            };
                        };
                        git_branch = {
                            symbol = "";
                            style = "bg:#394260";
                            format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
                        };
                        git_status = {
                            style = "bg:#394260";
                            format = "[[( $all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
                        };
                        nodejs = {
                            symbol = "";
                            style = "bg:#212736";
                            format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
                        };
                        rust = {
                            symbol = "";
                            style = "bg:#212736";
                            format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
                        };
                        golang = {
                            symbol = "";
                            style = "bg:#212736";
                            format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
                        };
                        php = {
                            symbol = "";
                            style = "bg:#212736";
                            format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
                        };
                        time = {
                            disabled = false;
                            time_format = "%R";
                            style = "bg:#1d2230";
                            format = "[[ $time ](fg:#a0a9cb bg:#1d2230)]($style)";
                        };
                    };
            };

    # Kitty configuration for all users
    environment.etc."kitty/kitty.conf".text = ''
        shell zsh
        font_family JetBrains Mono
        font_size 12.0
        enable_audio_bell no
        confirm_os_window_close 0
    '';

    # Fastfetch configuration with groups preset
    environment.etc."fastfetch/config.jsonc".text = ''
        {
            "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
            "logo": {
                "source": "~/.local/share/fastfetch/images/penrose-sky-wp.png",
                "type": "kitty",
                "height": 20,
                "padding": {
                    "top": 1
                }
            },
            "display": {
                "separator": " ➜  "
            },
            "modules": [
                "break",
                "break",
                "break",
                {
                    "type": "os",
                    "key": "OS   ",
                    "keyColor": "31",  // = color1
                },
                {
                    "type": "kernel",
                    "key": " ├  ",
                    "keyColor": "31",
                },
                {
                    "type": "packages",
                    "format": "{} (NixOS)",
                    "key": " ├ 󰏖 ",
                    "keyColor": "31",  
                },
                {
                    "type": "shell",
                    "key": " └  ",
                    "keyColor": "31", 
                },
                "break",
                {
                    "type": "wm",
                    "key": "WM   ",
                    "keyColor": "32", 
                },
                {
                    "type": "wmtheme",
                    "key": " ├ 󰉼 ",
                    "keyColor": "32",
                },
                {
                    "type": "icons",
                    "key": " ├ 󰀻 ",
                    "keyColor": "32",
                },
                {
                    "type": "cursor",
                    "key": " ├  ",
                    "keyColor": "32", 
                },
                {
                    "type": "terminal",
                    "key": " ├  ",
                    "keyColor": "32",
                },
                {
                    "type": "terminalfont",
                    "key": " └  ",
                    "keyColor": "32", 
                },
                "break",
                {
                    "type": "host",
                    "format": "{5} {1} Type {2}",
                    "key": "PC   ",
                    "keyColor": "33",
                },
                {
                    "type": "cpu",
                    "format": "{1} ({3}) @ {7} GHz",
                    "key": " ├  ",
                    "keyColor": "33",
                },
                {
                    "type": "gpu",
                    "format": "{1} {2} @ {12} GHz",            
                    "key": " ├ 󰢮 ",
                    "keyColor": "33",
                },
                {
                    "type": "memory",
                    "key": " ├  ",
                    "keyColor": "33",
                },
                {
                    "type": "swap",
                    "key": " ├ 󰓡 ",
                    "keyColor": "33",
                },
                {
                    "type": "disk",
                    "key": " ├ 󰋊 ",
                    "keyColor": "33",
                },
                {
                    "type": "monitor",
                    "key": " └  ",
                    "keyColor": "33",
                },
                "break",
                "break",
            ]
        }
    '';

}
