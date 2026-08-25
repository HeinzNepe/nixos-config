{ pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    # Prusa slicer for slicing software
    prusa-slicer

  ];

}
