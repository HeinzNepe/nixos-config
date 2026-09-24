{ pkgs, ... }:

{
  # Openconnect SSO package
  environment.systemPackages = with pkgs; [
    openconnect-sso
  ];
}