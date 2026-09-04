# minecraft.nix
# https://mich-murphy.com/nixos-minecraft-server/
# All The Mods 10: To the Sky (ATM10SKY) - Skyblock modpack for Minecraft 1.21.1 with NeoForge
# CurseForge Project: https://www.curseforge.com/minecraft/modpacks/all-the-mods-10-sky
# Project ID: 1298402

{
  config,
  pkgs,
  lib,
  ...
}:

let
  # ATM10 Sky modpack version 2.0.2 for Minecraft 1.21.1 with NeoForge
  # To get the correct hash, run:
  # nix-prefetch-url --unpack "https://media.forgecdn.net/files/6958/969/ATM10%20To%20the%20Sky-2.0.2.zip"
  # Then replace the sha256 hash below with the output
  modpack = pkgs.fetchurl {
    url = "https://media.forgecdn.net/files/6958/969/ATM10%20To%20the%20Sky-2.0.2.zip";
    sha256 = "sha256-0000000000000000000000000000000000000000000000000000";
  };
  
  # Extract the modpack to access its contents
  modpack-extracted = pkgs.runCommand "atm10-sky-extracted" {
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    mkdir -p $out
    cd $out
    unzip ${modpack} -d .
    # Remove the top-level directory if it exists (CurseForge zips often have one)
    if [ -d "ATM10 To the Sky-2.0.2" ]; then
      mv "ATM10 To the Sky-2.0.2"/* .
      rmdir "ATM10 To the Sky-2.0.2"
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

      # Symlink the mods directory from the extracted modpack
      symlinks = {
        "mods" = "${modpack-extracted}/mods";
      };
      
      # Copy configuration files from the extracted modpack
      files = {
        "config" = "${modpack-extracted}/config";
        "scripts" = "${modpack-extracted}/scripts";
      };
    };
  };
}