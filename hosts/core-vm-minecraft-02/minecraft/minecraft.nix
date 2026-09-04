# minecraft.nix
# https://mich-murphy.com/nixos-minecraft-server/

{
  config,
  pkgs,
  lib,
  ...
}:

# Change this file
let
  modpack = pkgs.fetchModrinthModpack {
    url = "https://cdn.modrinth.com/data/PROJECT_ID/versions/VERSION_ID/modpack.mrpack";
    packHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    side = "server";
  };
in
{
  services.minecraft-servers.servers.atm10 = {
    enable = true;
    package = pkgs.fabricServers.fabric-1_21_5.override { loaderVersion = "0.16.14"; };
    symlinks = {
      "mods" = "${modpack}/mods";
    };
    files = {
      "config" = "${modpack}/config";
    };
  };
}