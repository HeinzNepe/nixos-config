{ pkgs, inputs, ... }:

{
  # openconnect-sso was removed from nixpkgs, build it from the pinned fork
  # (see the openconnect-sso input in flake.nix).
  #
  # The fork's packaging reads pkgs.stdenv.isLinux, which is deprecated;
  # passing a patched pkgs redirects it to stdenv.hostPlatform.isLinux.
  nixpkgs.overlays = [
    (final: prev: {
      openconnect-sso =
        let
          openconnect = final.callPackage "${inputs.openconnect-sso}/nix/openconnect.nix" { };
          forkPkgs = final // {
            stdenv = final.stdenv // {
              isLinux = final.stdenv.hostPlatform.isLinux;
            };
          };
        in
        final.qt6.callPackage "${inputs.openconnect-sso}/nix/openconnect-sso.nix" {
          inherit openconnect;
          pkgs = forkPkgs;
        };
    })
  ];

  environment.systemPackages = with pkgs; [
    openconnect-sso
  ];
}