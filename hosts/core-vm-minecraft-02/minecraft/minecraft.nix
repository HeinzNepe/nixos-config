# minecraft.nix
# https://mich-murphy.com/nixos-minecraft-server/
# All The Mods 10: To the Sky (ATM10SKY) - Skyblock modpack for Minecraft 1.21.1 with NeoForge
# CurseForge Project: https://www.curseforge.com/minecraft/modpacks/all-the-mods-10-sky
# Project ID: 1298402
# Version: 2.0.2

{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Fetch the modpack from CurseForge CDN
  # ATM10 Sky 2.0.2 for Minecraft 1.21.1 with NeoForge
  # Hash verified via: sha256sum on downloaded file
  modpack = pkgs.fetchurl {
    url = "https://mediafilez.forgecdn.net/files/7854/204/ATM10%20To%20the%20Sky-2.0.2.zip";
    sha256 = "e3f60f24c2155b25a1ecf07c0d5d64fd25e7b320b6042a07b6031831da58ad80";
  };
  
  # Extract the modpack to access its contents
  modpack-extracted = pkgs.runCommand "atm10-sky-extracted" {
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    mkdir -p $out
    cd $out
    unzip ${modpack} -d .
    # Handle the directory structure - CurseForge/Modrinth packs often have a top-level folder
    if [ -d "ATM10 To the Sky-2.0.2" ]; then
      mv "ATM10 To the Sky-2.0.2"/* .
      rmdir "ATM10 To the Sky-2.0.2"
    elif [ -d "ATM10.To.the.Sky-2.0.2" ]; then
      mv "ATM10.To.the.Sky-2.0.2"/* .
      rmdir "ATM10.To.the.Sky-2.0.2"
    elif [ -d "overrides" ]; then
      # Some packs use 'overrides' as the root
      mv overrides/* .
      rmdir overrides
    fi
  '';
in
{
  # Minecraft server settings
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "/minecraft";
    servers.atm10-sky = {
      enable = true; # Enable this specific server configuration
      autoStart = true; # Automatically start the server on boot
      jvmOpts = "-Xmx8G -Xms4G"; # JVM options for memory allocation - adjust based on available RAM

      # Use NeoForge server for Minecraft 1.21.1 to match the modpack
      package = pkgs.neoforgeServers.neoforge-1_21_1;

      # Define server operators (admins) with their UUIDs
      operators = {
        "HeinzNepe" = {
          uuid = "dafc1b14-fdf3-4f76-bf61-83e88125e912";
          bypassesPlayerLimit = true;
        };
      };

      # Server properties configuration
      serverProperties = {
        server-port = 25566;
        difficulty = "normal";
        gamemode = "survival";
        max-players = 20;
        motd = "All The Mods 10: To the Sky - Skyblock Adventure!";
        online-mode = true;
        spawn-protection = 0;
        view-distance = 32;
      };

      # Symlink directories from the extracted modpack
      # Only include directories that exist in the modpack
      symlinks = {
        "mods" = "${modpack-extracted}/mods";
        "config" = "${modpack-extracted}/config";
      };
      
      # Files to copy (empty - we're using symlinks for everything)
      files = {};
    };
  };
}