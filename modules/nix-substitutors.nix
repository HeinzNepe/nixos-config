{ inputs, lib, pkgs, config, ... }:

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

}

