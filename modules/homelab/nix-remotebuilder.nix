{ inputs, lib, pkgs, config, ... }:

let
  manualBuilderKeyPath = "/var/lib/nix/builder-ssh-key";
  builderKeyPath = "/etc/nix/builder-ssh-key";
in
{

  #
  # Builder configuration
  #

  # SOPS configuration for builder SSH key (stored base64-encoded in the SOPS file)
  sops.secrets."builder-ssh-key-b64" = {
    sopsFile = ./../../secrets/service/builder.yaml;
    owner = "root";
    group = "root";
    mode = "0600";
  };

  # Enable distributed builds
  nix.distributedBuilds = true;

  # Allow builders to use substituters (can fetch from caches)
  nix.settings.builders-use-substitutes = true;

  # Remote build machine configuration
  nix.buildMachines = [{
    hostName = "core-vm-nixhelper-01";
    system = "x86_64-linux";
    sshUser = "remotebuild";
    # Prefer a manually managed key at /var/lib/nix/builder-ssh-key.
    # If that file is absent, the SOPS secret is decoded instead.
    sshKey = builderKeyPath;
    #maxJobs = 4;
    #speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    #mandatoryFeatures = [ ];
  }];

  # Decode the builder SSH key into /etc/nix/builder-ssh-key.
  # A manually managed key at /var/lib/nix/builder-ssh-key takes precedence.
  systemd.tmpfiles.rules = [
    "d /var/lib/nix 0700 root root -"
  ];

  systemd.services.decode-builder-ssh-key = {
    description = "Install builder SSH key";
    wantedBy = [ "multi-user.target" ];
    before = [ "nix-daemon.service" ];
    script = ''
      ${pkgs.coreutils}/bin/install -d -m 700 /etc/nix
      if [ -s ${manualBuilderKeyPath} ]; then
        ${pkgs.coreutils}/bin/install -m 600 ${manualBuilderKeyPath} ${builderKeyPath}
      else
        ${pkgs.coreutils}/bin/base64 --decode < ${config.sops.secrets."builder-ssh-key-b64".path} \
          | ${pkgs.coreutils}/bin/install -m 600 /dev/stdin ${builderKeyPath}
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
  };

}

