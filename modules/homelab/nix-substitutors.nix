{ inputs, pkgs, config, ... }:

{

  #
  # Binary cache configuration
  #


  # Binary cache configuration
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-cache.core.topheinz.com"
  ];

  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD2z8VEfzsIlCp8DWJfKgvLDdhmDtLrQz9z5z9E="
    "nix-cache.core.topheinz.com-1:kq/BstEjECBOnZQ8lv+K+UhMgiTeA8YQIhztrwrGqKE="
  ];

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
    # The sops secret `builder-ssh-key-b64` contains the key as base64.
    # Decode it at boot into a secure file that the Nix daemon can use.
    sshKey = "/etc/nix/builder-ssh-key";
    #maxJobs = 4;
    #speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    #mandatoryFeatures = [ ];
  }];

  # Decode base64 SSH key provided by sops into /etc/nix/builder-ssh-key
  systemd.services.decode-builder-ssh-key = {
    description = "Decode sops base64 builder SSH key";
    wantedBy = [ "multi-user.target" ];
    before = [ "nix-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        "" +
        "${pkgs.coreutils}/bin/mkdir" + " -p /etc/nix && " +
        "${pkgs.coreutils}/bin/base64" + " --decode < " + config.sops.secrets."builder-ssh-key-b64".path + " > /etc/nix/builder-ssh-key && " +
        "${pkgs.coreutils}/bin/chown" + " root:root /etc/nix/builder-ssh-key && " +
        "${pkgs.coreutils}/bin/chmod" + " 600 /etc/nix/builder-ssh-key";
      RemainAfterExit = "yes";
    };
  };

}

