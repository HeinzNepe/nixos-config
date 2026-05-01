# minecraft.nix — Maintenance Guide

This file documents how to maintain `minecraft.nix`, a [nix-minecraft](https://github.com/Infinidoge/nix-minecraft)-based NixOS module for running a Fabric Minecraft server.

**Current versions:** Minecraft `26.1.2` · Fabric `0.19.2` · Based on [Fabulously Optimized v26.1.2](https://modrinth.com/modpack/fabulously-optimized)

---

## Table of Contents

- [File Structure Overview](#file-structure-overview)
- [Installed Mods](#installed-mods)
- [Updating Minecraft or Fabric Versions](#updating-minecraft-or-fabric-versions)
- [Adding a Mod](#adding-a-mod)
- [Updating an Existing Mod](#updating-an-existing-mod)
- [Removing a Mod](#removing-a-mod)
- [Updating Server Properties](#updating-server-properties)
- [Applying Changes](#applying-changes)
- [Troubleshooting](#troubleshooting)

---

## File Structure Overview

```
minecraft.nix
├── mcVersion        — Minecraft version string (e.g. "26.1.2")
├── fabricVersion    — Fabric loader version string (e.g. "0.19.2")
├── serverVersion    — Derived from mcVersion; used to resolve the nix-minecraft package
└── services.minecraft-servers
    └── servers.fabulously-optimized
        ├── package          — Fabric server package with loader version override
        ├── serverProperties — Key/value server.properties settings
        └── symlinks.mods    — All mods declared as fetchurl derivations
```

Each mod entry follows this pattern:

```nix
ModName = pkgs.fetchurl {
  url    = "https://cdn.modrinth.com/data/<project-id>/versions/<version-id>/<filename>.jar";
  sha512 = "<sha512-hash>";
};
```

---

## Installed Mods

All mods in this file are confirmed server-compatible. Client-only mods from the original Fabulously Optimized mrpack have been removed.

### Core / API

| Mod | Version | Purpose |
|-----|---------|---------|
| `FabricApi` | 0.146.1 | Core Fabric API — required by most mods |
| `FabricLanguageKotlin` | 1.13.11 | Kotlin runtime — required by some mods |
| `ClothConfig` | 26.1.154 | Config library used by several mods |
| `YetAnotherConfigLib` | 3.9.2 | Config library used by several mods |
| `ForgeConfigApiPort` | 26.1.3 | Forge config API compatibility layer |
| `Ixeris` | 4.1.10 | Utility library |

### Performance

| Mod | Version | Purpose |
|-----|---------|---------|
| `Lithium` | 0.24.2 | Server-side tick and chunk optimisations |
| `FerriteCore` | 9.0.0 | Memory usage reduction |

### Gameplay / UI

| Mod | Version | Purpose |
|-----|---------|---------|
| `JustEnoughItems` | 26.1.1.25 | Recipe and item viewer — ⚠️ requires sha512 (see below) |
| `PaginatedAdvancements` | 2.8.0 | Paginated advancements screen |
| `NoChatReports` | 2.19.0 | Disables Mojang chat reporting |

### Utility / Misc

| Mod | Version | Purpose |
|-----|---------|---------|
| `Debugify` | 26.1.2.2 | Fixes known vanilla bugs |
| `CrashAssistant` | 1.11.8 | Improved crash reporting |
| `ConfigManager` | 1.1.2 | Config management |
| `Puzzle` | 2.3.1 | Mod resource pack loader utility |
| `E4mc` | 6.1.0 | LAN world sharing via relay |
| `Rrls` | 5.2.5 | Resource pack loading improvements |

---

## Updating Minecraft or Fabric Versions

1. Change the two version variables near the top of the file:

   ```nix
   mcVersion     = "26.1.2";   # ← new Minecraft version
   fabricVersion = "0.19.2";   # ← new Fabric loader version
   ```

2. Every mod in the `mods` block must have a version compatible with the new Minecraft version. Work through each mod and update it (see [Updating an Existing Mod](#updating-an-existing-mod)).

3. Check the [nix-minecraft releases](https://github.com/Infinidoge/nix-minecraft/releases) or source to confirm the new `fabricServers.<version>` attribute exists. If it does not yet exist, update your `nix-minecraft` flake input:

   ```bash
   nix flake update nix-minecraft
   ```

---

## Adding a Mod

1. Find the mod on [Modrinth](https://modrinth.com/mods) and navigate to the specific version you want.

2. Copy the **Version ID** from the version page (a short alphanumeric string shown in the version details panel).

3. Run the nix-minecraft prefetch helper to get the `url` and `sha512`:

   ```bash
   nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- <version-id>
   ```

   This prints a ready-to-paste `fetchurl` block.

4. Add the entry inside the `builtins.attrValues { ... }` block in `minecraft.nix`, under the appropriate category comment:

   ```nix
   MyNewMod = pkgs.fetchurl {
     url    = "https://cdn.modrinth.com/data/.../MyMod-1.0.0.jar";
     sha512 = "abc123...";
   };
   ```

5. Only add mods that are marked **"Client and server"** or **"Server-side"** on their Modrinth page. Client-only mods will either crash the server or silently do nothing.

---

## Updating an Existing Mod

1. Go to the mod's page on [Modrinth](https://modrinth.com) and find the version compatible with your current `mcVersion`.

2. Copy the **Version ID** for the new release.
  
    ```bash
    # If the download link is:
    https://cdn.modrinth.com/data/u6dRKJwZ/versions/riutbbC6/jei-26.1.2-fabric-29.5.0.27.jar

    # The version id is:
    riutbbC6
    ```

3. Run the prefetch helper:

   ```bash
   nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- <new-version-id>
   ```

4. In `minecraft.nix`, locate the mod by its attribute name and replace both the `url` and `sha512` with the output from step 3. Leave the attribute name unchanged unless you have a specific reason to rename it.

   ```nix
   # Before
   FabricApi = pkgs.fetchurl {
     url    = "https://cdn.modrinth.com/.../fabric-api-0.146.1+26.1.2.jar";
     sha512 = "cd8a760e...";
   };

   # After
   FabricApi = pkgs.fetchurl {
     url    = "https://cdn.modrinth.com/.../fabric-api-0.147.0+26.2.0.jar";
     sha512 = "newsha512...";
   };
   ```

5. Never edit a `sha512` manually — always take it from the prefetch tool. A wrong hash will cause the build to fail with a hash mismatch error.

---

## Removing a Mod

Delete the entire attribute block for the mod from the `builtins.attrValues { ... }` set:

```nix
# Remove this entire block:
SomeMod = pkgs.fetchurl {
  url    = "...";
  sha512 = "...";
};
```

Make sure no other mod in the list declares a dependency on the one being removed, or the server may fail to start.

---

## Updating Server Properties

Server behaviour is controlled by the `serverProperties` block:

```nix
serverProperties = {
  server-port = 25565;
  gamemode    = "survival";
  motd        = "Fabulously Optimized";
  max-players = 20;
};
```

Keys map directly to `server.properties` field names. Common properties you may want to change:

| Key | Description | Example |
|-----|-------------|---------|
| `server-port` | Port the server listens on | `25565` |
| `gamemode` | Default gamemode | `"survival"`, `"creative"`, `"adventure"` |
| `difficulty` | World difficulty | `"easy"`, `"normal"`, `"hard"` |
| `max-players` | Maximum concurrent players | `20` |
| `motd` | Message shown in server list | `"My Server"` |
| `level-seed` | World generation seed | `"12345"` |
| `online-mode` | Enforce Mojang authentication | `true` / `false` |
| `white-list` | Enable whitelist | `true` / `false` |

A full list of valid keys is available in the [Minecraft wiki](https://minecraft.wiki/w/Server.properties).

---

## Applying Changes

After any edit to `minecraft.nix`, rebuild and switch your NixOS configuration:

```bash
sudo nixos-rebuild switch --flake .#<your-hostname>
```

The nix-minecraft module manages the server as a systemd service. After rebuilding, the service restarts automatically. You can check its status with:

```bash
systemctl status minecraft-server-fabulously-optimized
journalctl -u minecraft-server-fabulously-optimized -f
```

To restart the server manually without a full rebuild:

```bash
sudo systemctl restart minecraft-server-fabulously-optimized
```

---

## Troubleshooting

**Hash mismatch error during build**
The `sha512` in the file doesn't match the downloaded jar. Re-run the prefetch tool for that mod and replace the hash. Never copy hashes manually — always use `nix-modrinth-prefetch`.

**`fabricServers.<version>` attribute not found**
The Minecraft or Fabric version isn't available in your current `nix-minecraft` revision. Run `nix flake update nix-minecraft` and try again. For very new releases there may be a short delay before nix-minecraft adds support.

**Server crashes on startup with `ClassNotFoundException` or `ModLoadingException`**
A mod in the list has an unmet dependency or is incompatible with the current Minecraft version. Check the server log at `journalctl -u minecraft-server-fabulously-optimized` and update or remove the offending mod.

**Server starts but a mod doesn't work**
The mod version may not be compatible with the current `mcVersion`. Check Modrinth for a compatible release and update accordingly.

**`eula = true` is required**
By setting `eula = true` in the config, you are agreeing to the [Minecraft End User License Agreement](https://www.minecraft.net/en-us/eula). The server will not start without it.
