{ pkgs, inputs, ... }:

{
  # Add the openconnect-sso package from the pinned fork flake input
  nixpkgs.overlays = [
    (import "${inputs.openconnect-sso.outPath}/overlay.nix")
  ];

  # Openconnect SSO package
  environment.systemPackages = with pkgs; [
    openconnect-sso
  ];
}
