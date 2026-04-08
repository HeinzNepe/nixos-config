# NixOS FR24 Feeder for Raspberry Pi

A fully declarative NixOS configuration that turns a Raspberry Pi into a
headless FlightRadar24 ADS-B feeder.

## Hardware you need

| Part | Notes |
|------|-------|
| Raspberry Pi 3B+, 4, 400, or Zero 2 W | 64-bit (aarch64) models only |
| RTL-SDR dongle (RTL2832U-based) | RTL-SDR Blog V3 or V4 recommended |
| 1090 MHz ADS-B antenna | Comes with most RTL-SDR kits |
| microSD card ≥ 8 GB | Class 10 / A1 recommended |
| Ethernet cable **or** WiFi credentials | Wired is more reliable |

---

## How it works

```
RTL-SDR dongle (USB, 1090 MHz)
        │
   dump1090-fa    (aarch64, from nixpkgs)
        │   Beast TCP :30005
   fr24feed       (32-bit armhf binary, wrapped in FHS env)
        │
   FlightRadar24
```

`dump1090-fa` decodes raw ADS-B signals from your SDR dongle and streams them
as Beast-format TCP on port 30005. `fr24feed` connects to that stream and
forwards the data to FlightRadar24's servers.

### Why a FHS wrapper for fr24feed?

FlightRadar24 only distributes `fr24feed` as a 32-bit ARM (armhf) binary.
NixOS is a pure 64-bit (aarch64) system with no FHS directory structure.
The configuration enables `binfmt_misc` so the kernel can execute 32-bit ARM
ELFs via QEMU, and wraps the binary in a `buildFHSEnv` sandbox that provides
the 32-bit glibc the binary expects.

---

## Setup steps

### 1. Edit `configuration.nix`

Open `configuration.nix` and fill in every `TODO`:

```nix
hostname = "fr24-feeder";     # your preferred hostname
fr24Key  = "";                # leave blank for first boot
antLat   = "59.9139";        # your antenna latitude (4 decimal places)
antLon   = "10.7522";        # your antenna longitude
antAlt   = "30";             # metres above sea level (in feet!)
```

Also add your SSH public key:

```nix
openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3... you@host"
];
```

### 2. Get the real SHA-256 for the fr24feed binary

```bash
nix-prefetch-url \
  https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_1.0.48-0_armhf.deb
```

Paste the printed hash into `configuration.nix`:

```nix
sha256 = "sha256-<hash printed above>";
```

### 3. Enable aarch64 emulation on your build machine (if not already done)

If you're building from an x86_64 machine, add this to that machine's
`/etc/nixos/configuration.nix` and rebuild:

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

### 4. Build the SD card image

```bash
nix build .#nixosConfigurations.fr24-feeder.config.system.build.sdImage
```

### 5. Flash the image

```bash
sudo dd \
  if=result/sd-image/nixos-sd-image-*.img \
  of=/dev/sdX \          # replace sdX with your card device
  bs=4M status=progress conv=fsync
```

### 6. First boot

1. Insert the SD card, connect the RTL-SDR dongle + antenna, then power on.
2. SSH in: `ssh pi@fr24-feeder` (or use the IP address).
3. If you left `fr24Key` empty, generate a key:
   ```bash
   sudo fr24feed --signup
   ```
   Follow the prompts, save the key that is emailed to you, then add it to
   `configuration.nix` and redeploy (step 7).

### 7. Subsequent updates

```bash
nixos-rebuild switch \
  --flake .#fr24-feeder \
  --target-host pi@fr24-feeder \
  --use-remote-sudo
```

---

## Useful commands on the Pi

| Command | Purpose |
|---------|---------|
| `systemctl status dump1090` | Is the ADS-B decoder running? |
| `systemctl status fr24feed` | Is the feeder running? |
| `sudo journalctl -fu fr24feed` | Live fr24feed logs |
| `rtl_test` | Verify the SDR dongle is detected |
| `curl http://localhost:8754` | fr24feed status page |
| `curl http://localhost:8080` | dump1090 aircraft map |

---

## Choosing the right Pi hardware module

In `flake.nix`, uncomment the line matching your Pi:

```nix
nixos-hardware.nixosModules.raspberry-pi-4        # RPi 4 / 400 / CM4
# nixos-hardware.nixosModules.raspberry-pi-3      # RPi 3B / 3B+
# nixos-hardware.nixosModules.raspberry-pi-zero-2 # RPi Zero 2 W
```

---

## Notes

- **MLAT** requires that your lat/lon/alt are accurate and that system time is
  synced (handled automatically by `timesyncd`).
- **Multiple feeders per account**: FR24 allows up to 3 feeders per account.
  Contact support if you need more.
- **Updates**: FR24 periodically deprecates older `fr24feed` versions. Update
  the `version` and `sha256` in `configuration.nix` when needed.
- **Firewall**: By default ports 22, 8080, 8754, and 30005 are open on the
  local network. Adjust `allowedTCPPorts` in `configuration.nix` to taste.
