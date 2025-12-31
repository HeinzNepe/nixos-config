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
}
