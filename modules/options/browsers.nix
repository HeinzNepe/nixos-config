{ pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    # Web browsers
    vivaldi
    firefox
  ];
}