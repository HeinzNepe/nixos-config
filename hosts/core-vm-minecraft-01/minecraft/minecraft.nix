# minecraft.nix
# Generated from Fabulously Optimized v26.1.2 (Minecraft 26.1.2, Fabric 0.19.2)
# Client-only mods removed. JEI added.
# https://mich-murphy.com/nixos-minecraft-server/

{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.common.minecraft;
  mcVersion = "26.1.2";
  fabricVersion = "0.19.2";
  serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
in {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  options.common.minecraft = {
    enable = mkEnableOption "Enable Minecraft Server";
  };

  config = mkIf cfg.enable {
    services = {
      minecraft-servers = {
        enable = true;
        eula = true;
        dataDir = "/minecraft/2026-04-25-fabulously-optimized"; 
        servers.fabulously-optimized = {
          enable = true;
          package = pkgs.fabricServers.${serverVersion}.override { loaderVersion = fabricVersion; };
          serverProperties = {
            server-port = 25565;
            gamemode = "survival";
            motd = "Fabulously Optimized";
            max-players = 20;
          };
          symlinks = {
            mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {

              # ----------------------------------------------------------------
              # Core / API
              # ----------------------------------------------------------------

              FabricApi = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/tnmuHGZA/fabric-api-0.146.1%2B26.1.2.jar";
                sha512 = "cd8a760ecb976127036f8047c1e968f264aea9cd9deca60e6e9cb57496b1b5cca79873c59b7ab46b92f49ac22f49a2b695bb6ebe61653c8df6954e97b8836890";
              };

              FabricLanguageKotlin = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/2i87JpYj/fabric-language-kotlin-1.13.11%2Bkotlin.2.3.21.jar";
                sha512 = "fa5ed2613f7216999cc0c5ddc71906f082a32b52507d7160acbdcf0eb8de12993ba302e5afde6681d025008ecc66c7533fc0c21deb672ef681b2194fb9be4245";
              };

              ClothConfig = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/9s6osm5g/versions/GFM8zh9J/cloth-config-26.1.154.jar";
                sha512 = "8bfb75f2cac0a9910316c6a368a228c0f8f1261ac6f03dec5fba594e1619ac04334a3df4fb29778d61d0b8290d55949371a523d722b35501bf9a2902956d3b17";
              };

              YetAnotherConfigLib = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/1eAoo2KR/versions/h2FGeDHG/yet_another_config_lib_v3-3.9.2%2B26.1-fabric.jar";
                sha512 = "0efbc7bbf9cabcf5f78884eab0b85ca902e6ca7dfa07b60c1c812b828442b940e80c459fd3de8b87cae50bba3c203efc4444a8e29d21b94ad1ad12d438f91a58";
              };

              ForgeConfigApiPort = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/ohNO6lps/versions/RXbL43Lt/ForgeConfigAPIPort-v26.1.3-mc26.1.x-Fabric.jar";
                sha512 = "96cb9a0ce20622c844d7b5d04e250d0c6b7026972d0680c5d60c731546578cdf20d5ad898ac81e87744f5805e191f05c8598fc6e1175a97ece3bbb48afbc77b2";
              };

              Ixeris = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/p8RJPJIC/versions/6zryDipI/Ixeris-4.1.10%2B26.1.2-fabric.jar";
                sha512 = "e7c865b2e4766849addb0c88de345952388fc99625fcb5d24bcaaec47be8ead0a98a07984a3bcf3c7c666351588acae0d3ecabeb6ca35da2205edf3a22519df8";
              };

              # ----------------------------------------------------------------
              # Performance
              # ----------------------------------------------------------------

              Lithium = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/R7MxYvuW/lithium-fabric-0.24.2%2Bmc26.1.2.jar";
                sha512 = "9231ad05667d4eef0348c700bf5160929e0b723d9e145fd97c7fcef9387ac2e6d524fb15d99f47f8f838f1d235324fd750cdcb6603b63aab6085d79fbeaab31b";
              };

              FerriteCore = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar";
                sha512 = "d81fa97e11784c19d42f89c2f433831d007603dd7193cee45fa177e4a6a9c52b384b198586e04a0f7f63cd996fed713322578bde9a8db57e1188854ae5cbe584";
              };

              # ----------------------------------------------------------------
              # Entity rendering (server-side components)
              # ----------------------------------------------------------------

              EntityModelFeatures = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/4I1XuqiY/versions/awv0MUoS/entity_model_features_26.1-fabric-3.1.1.jar";
                sha512 = "813f146d5f551706be15eaa3dfa902d74198bb050b75be37019eda0609c54f200d4eb523773ec791712882a38019478314bddd15ec9771b56cd62c27687a8eb8";
              };

              EntityTextureFeatures = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/BVzZfTc1/versions/pzW03Rc5/entity_texture_features_26.1-fabric-7.1.jar";
                sha512 = "9d740d901f691a5b9fb1eaa4acec488c9ceba2fa90742a8ca66f60a303b28c388cd2da8a6d2aac1aef3b0783bfeea5843657938bd6a5810e468ef7be12bd2b8b";
              };

              # ----------------------------------------------------------------
              # Gameplay / UI (server-compatible)
              # ----------------------------------------------------------------

              # JEI — recipe viewer; supports both client and server (v26.1.1.25)
              # To get the sha512, run on a system with nix flakes enabled:
              #   nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- wUnAuqGV
              # Then replace the sha512 value below with the output.
              JustEnoughItems = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/u6dRKJwZ/versions/wUnAuqGV/jei-1.21.10-fabric-26.1.1.25.jar";
                sha512 = "1acef022b97deb6d6f7ee096fa6244dc835883f3351c549363788c4d723d443d78a35d928ac5d441db755f33bd6a85f2b9d445ac5963b6150f059a2a86f0e9f2";
              };

              PaginatedAdvancements = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/pJogNFap/versions/4c7iLjw0/paginatedadvancements-2.8.0%2B26.1.jar";
                sha512 = "79a260602401663ce79eb693dbcd878ee0f8e828cf7f30745d21198c9f07a3fa6f0377153b3f7c0b99b2b7cf07d87a58f006885bb1e66728f6029081431a88b3";
              };

              NoChatReports = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/2yrLNE3S/NoChatReports-FABRIC-26.1-v2.19.0.jar";
                sha512 = "94d58a1a4cde4e3b1750bdf724e65c5f4ff3436c2532f36a465d497d26bf59f5ac996cddbff8ecdfed770c319aa2f2dcc9c7b2d19a35651c2a7735c5b2124dad";
              };

              # ----------------------------------------------------------------
              # Utility / misc
              # ----------------------------------------------------------------

              Debugify = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/AYdf2KSj/debugify-26.1.2.2.jar";
                sha512 = "5b22b8c43216817020b051dc265c135bb22f44da03435c64b1cec9838a2ec3dfa2c49327711481943166fc57694d551c8fdb3d2c5aa23f4737eff9182b0bb5e7";
              };

              CrashAssistant = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/ix1qq8Ux/versions/klyidF0J/CrashAssistant-fabric-26.1-1.11.8.jar";
                sha512 = "b91da396eb5c52595d1f9320b2afc75d19881f29a1d1ab3c244a3900e066f653c7d1523548704c747bc7784374673fffa685d54ee6fe1ea8f7beb849a74191ea";
              };

              ConfigManager = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/jlNms3Jp/versions/wOTuMBMb/ConfigManager-fabric-26.1-1.1.2.jar";
                sha512 = "b8714845dd4eba6397502a4c3ea19e83e9ba2edb8d32d004b78fa736b7de46f4e6123ffbe2b1149b78fb63cc778df32bb7b319a769e90bfdd7b80aaaad22d99e";
              };

              Puzzle = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/3IuO68q1/versions/M6In6JRO/puzzle-fabric-2.3.1%2B26.1.jar";
                sha512 = "ff9423c0f54d2c151714347575839942199f9dbfdd9233b9c7fd548399250692bff66e022c7fbeb0ab5f5ab21c269e005eeb7573a6e9cb2b5f750a004f9d725e";
              };

              Rrls = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/ZP7xHXtw/versions/LYRXlhmw/rrls-5.2.5%2Bmc.26.1.jar";
                sha512 = "4ebcdd2e1c68345ffd73bab58e7a7d73e48f12ad57de1136bb9f1bd64e2d33ce8bc2c97015e63c8de884da23cc7e6c61d9a245de25a77877625f468bc3742dab";
              };

            });
          };
        };
      };
    };
  };
}
