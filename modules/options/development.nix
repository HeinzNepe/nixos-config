{ pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    # GitHub CLI
    gh

    # JetBrains apps
    jetbrains.datagrip
    jetbrains.gateway
    jetbrains.rider
    jetbrains.webstorm

    # Desktop app
    postman

    # Visual Studio Code
    vscode
  ];

  # Enable direnv
  # - Direnv lets you load and unload environment variables depending on the current directory.
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
