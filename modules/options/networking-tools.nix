{ pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    # Networking tools
    dig         # dig for DNS lookups
    wireshark   # wireshark network protocol analyzer
    nmap        # network scanner
    net-tools   # ifconfig, netstat, route, etc.
    iperf       # network bandwidth measurement tool
    mtr         # network diagnostic tool
  ];
}
