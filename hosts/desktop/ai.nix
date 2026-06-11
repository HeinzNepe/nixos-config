{ config, pkgs, lib, ... }:

{
  #### ---------------------------------------------------------
  ####  AMD GPU + ROCm + Vulkan
  #### ---------------------------------------------------------
  hardware.graphics = {
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.rocblas
      rocmPackages.rocrand
      rocmPackages.rocm-device-libs
    ];
  };

  # HIP path fix
  systemd.tmpfiles.rules = [
    "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
  ];

  #### ---------------------------------------------------------
  ####  Ollama (Claude-Code-like backend)
  #### ---------------------------------------------------------
  services.ollama = {
    enable = true;
    #package = pkgs.ollama-rocm;
    package = pkgs.ollama-vulkan;
    host = "127.0.0.1";
    port = 11434;
  };

  /*
  Pulling the AI model:
  ollama pull qwen2.5-coder:14b

  */


  #### ---------------------------------------------------------
  ####  Developer tools for agentic coding
  #### ---------------------------------------------------------
  environment.systemPackages = with pkgs; [
    ollama
    opencode
    python3
  ];

  #### ---------------------------------------------------------
  ####  User permissions
  #### ---------------------------------------------------------
  users.users.henrik = {
    extraGroups = [ "video" "render" ];
  };

  #### ---------------------------------------------------------
  ####  Firewall rules (optional)
  #### ---------------------------------------------------------
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
