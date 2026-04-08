# =============================================================================
# NixOS configuration for a Raspberry Pi FlightRadar24 ADS-B feeder
#
# Architecture overview
# ─────────────────────
#  RTL-SDR dongle (USB, 1090 MHz)
#       │
#  dump1090-fa  ← decodes ADS-B; exposes Beast TCP on :30005 + HTTP map on :8080
#       │
#  fr24feed     ← reads Beast TCP, forwards to FlightRadar24
#
# fr24feed note
# ─────────────
# The fr24feed binary is only available as a 32-bit ARM (armhf) ELF.
# On a 64-bit NixOS system we enable binfmt for armv7l so the kernel can
# execute 32-bit ARM binaries, and we use buildFHSEnv to give it the 32-bit
# glibc it expects.  dump1090-fa is compiled natively (aarch64) from nixpkgs.
#
# Quick-start guide
# ─────────────────
# 1. Edit every TODO below (hostname, SSH key, WiFi creds, lat/lon/alt, FR24 key).
# 2. Get the real SHA-256 of the fr24feed armhf deb:
#      nix-prefetch-url https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_1.0.48-0_armhf.deb
#    Then paste the hash into `sha256 =` in fr24feedBin below.
# 3. If building from an x86_64 machine, first add to that machine's config:
#      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
# 4. Build the SD image:
#      nix build .#nixosConfigurations.fr24-feeder.config.system.build.sdImage
# 5. Flash:
#      sudo dd if=result/sd-image/*.img of=/dev/sdX bs=4M status=progress conv=fsync
# 6. Boot the Pi.  If fr24Key is empty, SSH in and run:
#      sudo fr24feed --signup
#    Then add the key to configuration.nix and rebuild:
#      nixos-rebuild switch --flake .#fr24-feeder --target-host pi@<IP> --use-remote-sudo
# =============================================================================

{ config, pkgs, lib, ... }:

let
  # ── USER SETTINGS – fill these in ─────────────────────────────────────────

  hostname = "fr24-feeder";      # hostname visible on your network

  # Your FlightRadar24 sharing key.
  # Leave empty string on first boot; run `sudo fr24feed --signup` to generate.
  fr24Key = "";                  # e.g. "a1b2c3d4e5f60708"

  # Antenna position – required for MLAT multilateration
  antLat = "0.0000";             # TODO  latitude  to 4 decimal places
  antLon = "0.0000";             # TODO  longitude to 4 decimal places
  antAlt = "50";                 # TODO  altitude above sea level in feet

  # Set to "yes" once you have a valid fr24Key; needs accurate GPS position above
  mlat = if fr24Key == "" then "no" else "yes";

  # ── END USER SETTINGS ──────────────────────────────────────────────────────


  # ---------------------------------------------------------------------------
  # fr24feed derivation
  #
  # FlightRadar24 distributes fr24feed only as a 32-bit ARM (armhf) .deb.
  # We unpack it and wrap it in an FHS environment so it finds the correct
  # 32-bit glibc on the 64-bit NixOS host.
  # ---------------------------------------------------------------------------

  fr24feedBin = pkgs.stdenv.mkDerivation rec {
    pname   = "fr24feed-bin";
    version = "1.0.48-0";

    src = pkgs.fetchurl {
      url = "https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_${version}_armhf.deb";
      # Run `nix-prefetch-url <url>` and paste the result here:        # TODO
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    nativeBuildInputs = [ pkgs.dpkg ];

    unpackPhase = "dpkg-dex -x $src unpacked";

    installPhase = ''
      mkdir -p $out/bin $out/lib/fr24
      install -m 0755 unpacked/usr/bin/fr24feed  $out/bin/fr24feed
      cp -r unpacked/usr/lib/fr24/.              $out/lib/fr24/
    '';

    # fr24feed is a statically linked 32-bit ARM ELF; skip NixOS ELF patching.
    dontPatchELF = true;
    dontStrip    = true;
  };

  # Wrap the binary in an FHS user environment that provides 32-bit ARM libs.
  fr24feed = pkgs.buildFHSEnv {
    name = "fr24feed";

    # Provide the 32-bit ARM runtime libraries that the binary needs.
    targetPkgs = _pkgs: with pkgs.pkgsCross.armv7l-hf-multiplatform; [
      glibc
      stdenv.cc.cc.lib
    ];

    # Make the actual binary reachable inside the FHS tree.
    extraInstallCommands = ''
      mkdir -p $out/usr/bin
      ln -s ${fr24feedBin}/bin/fr24feed $out/usr/bin/fr24feed
      ln -s ${fr24feedBin}/lib/fr24     $out/usr/lib/fr24
    '';

    runScript = "fr24feed";
  };

  # ---------------------------------------------------------------------------
  # /etc/fr24feed.ini – written declaratively
  #
  # receiver=beast-tcp tells fr24feed to connect to dump1090's Beast TCP port
  # instead of trying to open the USB dongle directly (which dump1090 already owns).
  # ---------------------------------------------------------------------------
  fr24feedIni = pkgs.writeText "fr24feed.ini" (lib.concatStringsSep "\n" [
    ''receiver="beast-tcp"''
    ''host="127.0.0.1:30005"''
    ''fr24key="${fr24Key}"''
    ''radar_server="data.fr24.com"''
    ''port=10001''
    ''bs=no''
    ''raw=no''
    ''logmode=1''
    ''logpath="/var/log/fr24feed"''
    ''mlat="${mlat}"''
    ''mlat-without-gps=no''
    ''lat=${antLat}''
    ''lon=${antLon}''
    ''alt=${antAlt}''
  ]);

in {

  # ===========================================================================
  # nixpkgs
  # ===========================================================================
  nixpkgs = {
    hostPlatform = "aarch64-linux";
    config = {
      allowUnfree = true;            # fr24feed has a proprietary licence
      allowUnsupportedSystem = true; # allow 32-bit ARM cross packages
    };
  };

  # Enable binfmt_misc so 32-bit ARM ELFs execute transparently on this
  # aarch64 host (via QEMU user-mode emulation built into the kernel).
  boot.binfmt.emulatedSystems = [ "armv7l-linux" ];

  # Faster SD image builds (ZFS support causes long compiles on aarch64)
  boot.supportedFilesystems.zfs = lib.mkForce false;
  sdImage.compressImage = false;

  # ===========================================================================
  # Boot loader
  # ===========================================================================
  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  # ===========================================================================
  # Kernel & hardware
  # ===========================================================================

  # Blacklist the kernel's built-in DVB/TV drivers that automatically claim
  # the RTL2832U USB chip, preventing rtl-sdr (and therefore dump1090) from
  # opening the device.
  boot.blacklistedKernelModules = [
    "dvb_usb_rtl28xxu"
    "rtl2832"
    "rtl2830"
    "rtl2832_sdr"
    "rtl8xxxu"
  ];

  # Install RTL-SDR udev rules so the dongle is accessible without root
  hardware.rtl-sdr.enable = true;

  # ===========================================================================
  # Networking
  # ===========================================================================
  networking = {
    hostName = hostname;
    useDHCP  = lib.mkDefault true;   # wired Ethernet via DHCP (recommended)

    # ── WiFi – uncomment and fill in if running headless over WiFi ────────────
    # wireless = {
    #   enable = true;
    #   networks = {
    #     "YOUR_SSID" = {              # TODO
    #       psk = "YOUR_PASSPHRASE";   # TODO
    #     };
    #   };
    # };

    firewall = {
      enable          = true;
      allowedTCPPorts = [
        22    # SSH
        8080  # dump1090-fa map UI
        8754  # fr24feed status UI
        30005 # Beast TCP (useful if you want other feeders to connect)
      ];
    };
  };

  # ===========================================================================
  # Time  (accurate time is required for MLAT)
  # ===========================================================================
  time.timeZone        = "Europe/Oslo"; # TODO: adjust if needed
  services.timesyncd.enable = true;

  # ===========================================================================
  # SSH
  # ===========================================================================
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin             = "no";
      PasswordAuthentication      = false;  # key-only access
    };
  };

  # ===========================================================================
  # Users
  # ===========================================================================
  users.users.pi = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "plugdev" ]; # wheel → sudo, plugdev → USB devices
    openssh.authorizedKeys.keys = [
      # TODO: replace with your own public key
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... you@host"
    ];
  };

  # Passwordless sudo for convenience on a dedicated appliance
  security.sudo.wheelNeedsPassword = false;

  # System user that runs fr24feed
  users.users.fr24feed = {
    isSystemUser = true;
    group        = "fr24feed";
    description  = "FlightRadar24 feeder daemon";
  };
  users.groups.fr24feed = {};

  # ===========================================================================
  # dump1090-fa  –  native aarch64 ADS-B decoder
  # ===========================================================================
  services.dump1090 = {
    enable = true;
    extraConfig = [
      "--net"
      "--net-beast-port"    "30005"   # Beast TCP for fr24feed
      "--net-sbs-port"      "30003"   # SBS/BaseStation output
      "--net-raw-out-port"  "30002"   # raw AVR output
      "--lat"               antLat    # for range rings on the map
      "--lon"               antLon
      "--max-range"         "450"     # nm; 300-450 is typical with a good antenna
      "--write-json"        "/run/dump1090"  # powers the web map
    ];
  };

  # ===========================================================================
  # fr24feed  –  FlightRadar24 uplink (32-bit armhf wrapped in FHS env)
  # ===========================================================================

  # Install the config file fr24feed reads on startup
  environment.etc."fr24feed.ini".source = fr24feedIni;

  # Persistent runtime and log directories
  systemd.tmpfiles.rules = [
    "d /var/log/fr24feed 0755 fr24feed fr24feed -"
    "d /run/fr24feed     0755 fr24feed fr24feed -"
  ];

  systemd.services.fr24feed = {
    description = "FlightRadar24 ADS-B feeder";

    # Wait for the network and for dump1090 to be up before starting
    after    = [ "network-online.target" "dump1090.service" ];
    wants    = [ "network-online.target" ];
    requires = [ "dump1090.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type      = "simple";
      User      = "fr24feed";
      Group     = "fr24feed";
      ExecStart = "${fr24feed}/bin/fr24feed --config=/etc/fr24feed.ini";

      # Restart automatically if fr24feed crashes or disconnects
      Restart    = "on-failure";
      RestartSec = "15s";

      # Light sandboxing – fr24feed only needs network and log access
      NoNewPrivileges = true;
      PrivateTmp      = true;
    };
  };

  # ===========================================================================
  # System packages
  # ===========================================================================
  environment.systemPackages = with pkgs; [
    rtl-sdr      # rtl_test, rtl_sdr, rtl_fm – useful for debugging the dongle
    tcpdump      # packet capture for debugging
    curl
    wget
    htop
    lsof
    fr24feed     # also available directly on PATH as `fr24feed`
  ];

  # ===========================================================================
  # Nix maintenance
  # ===========================================================================
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 14d";
  };

  system.stateVersion = "24.11";
}
