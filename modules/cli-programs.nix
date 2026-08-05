{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Basic CLI tools
    vim       # Vim text editor
    wget      # Network downloader
    tmux      # Terminal multiplexer
    lazygit   # Git UI
    lf        # Terminal file manager
    fastfetch # System information tool
    sbctl     # Secure boot management program
    htop      # Process management
  ];

  # Enable Git and Git LFS
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
    };
  };

}

