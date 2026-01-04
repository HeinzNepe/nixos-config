{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Basic CLI tools
    vim       # Vim text editor
    wget      # Network downloader
    tmux      # Terminal multiplexer
    git       # Version control system
    lazygit   # Git UI
    lf        # Terminal file manager
    fastfetch # System information tool
    sbctl     # Secure boot management program
    htop      # Process management
  ];

}

