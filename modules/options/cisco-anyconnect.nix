{ pkgs, inputs, ... }:

{
  # openconnect-sso was removed from nixpkgs, build it from the pinned fork
  # (see the openconnect-sso input in flake.nix).
  nixpkgs.overlays = [
    (final: prev: {
      openconnect-sso =
        let
          openconnect = final.callPackage "${inputs.openconnect-sso}/nix/openconnect.nix" { };
          # The fork's packaging reads the deprecated
          # pkgs.stdenv.{system,isDarwin,isLinux}, which now emit evaluation
          # warnings; redirecting them to the stdenv.hostPlatform equivalents.
          forkPkgs = final // {
            stdenv = final.stdenv // {
              system = final.stdenv.hostPlatform.system;
              isDarwin = final.stdenv.hostPlatform.isDarwin;
              isLinux = final.stdenv.hostPlatform.isLinux;
            };
          };
        in
        (final.qt6.callPackage "${inputs.openconnect-sso}/nix/openconnect-sso.nix" {
          inherit openconnect;
          pkgs = forkPkgs;
        }).overrideAttrs (old: {
          # The fork's expression also sets a Nix attr
          # makeWrapperArgs = [ "\${qtWrapperArgs[@]}" ].
          # Structured attrs export that list verbatim, so the literal
          # string "${qtWrapperArgs[@]}" is passed to makeCWrapper and the
          # build fails with "Unknown argument". Drop it; the package's
          # preFixup already appends the qt wrapper args in shell, where
          # they are expanded properly.
          makeWrapperArgs = [ ];
        });
    })
  ];

  environment.systemPackages = with pkgs; [
    openconnect-sso
  ];
}
