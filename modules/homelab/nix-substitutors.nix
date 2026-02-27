{ inputs, pkgs, config, ... }:

{

  # Binary cache configuration
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://nix-cache.core.topheinz.com"
  ];

  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD2z8VEfzsIlCp8DWJfKgvLDdhmDtLrQz9z5z9E="
    "nix-cache.core.topheinz.com-1:kq/BstEjECBOnZQ8lv+K+UhMgiTeA8YQIhztrwrGqKE="
  ];

  # SOPS configuration for builder SSH key
  sops.secrets."builder-ssh-key" = {
    sopsFile = ./../../secrets/service/builder.yaml;
    owner = "root";
    group = "root";
    mode = "0600";
  };

  # Remote build machine configuration
  nix.buildMachines = [{
    hostName = "core-vm-nixhelper-01.core.topheinz.com";
    system = "x86_64-linux";
    user = "nixbuilder";
    sshKey = config.sops.secrets."builder-ssh-key".path;
    maxJobs = 4;
    speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
  }];

  # Enable distributed builds
  nix.distributedBuilds = true;

  # Allow builders to use substituters (can fetch from caches)
  nix.settings.builders-use-substitutes = true;
}

