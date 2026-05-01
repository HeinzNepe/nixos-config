# minecraft.nix
# https://mich-murphy.com/nixos-minecraft-server/

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Minecraft server settings
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "/minecraft";
    servers.fabric-server = {
      enable = true; # Enable this specific server configuration
      autoStart = true; # Automatically start the server on boot
      jvmOpts = "-Xmx4G -Xms2G"; # JVM options for memory allocation

      # Specify the custom minecraft server package
      package = pkgs.fabricServers.fabric-26_1_2.override { jre_headless = pkgs.openjdk25_headless; };

      # Define server operators (admins) with their UUIDs
      operators = {
        "HeinzNepe" = {
          uuid = "dafc1b14-fdf3-4f76-bf61-83e88125e912";
          bypassesPlayerLimit = true;
        };
      };

      # Server properties configuration
      serverProperties = {
        server-port = 25565;
        difficulty = "normal";
        gamemode = "survival";
        max-players = 20;
        motd = "A declarative Minecraft server managed by NixOS!";
        online-mode = true;
        spawn-protection = 0;
        view-distance = 10;
      };
    };
  };
}