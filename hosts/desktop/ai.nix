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
  Pulling AI models for Ollama (done once per model):
    - ollama pull gemma4:latest
  To update the model later:
    - ollama pull gemma4:latest

  Usage:
  - Start Ollama service (auto by NixOS if enabled above).
  - Start pi in your terminal: `pi` (after installing with npm globally, see below)
  - Switch model in pi with `/model ollama/gemma4`

  ## pi.coding.agent install notes
  Install pi via npm (recommended):
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
  Alternate (or for updates):
    curl -fsSL https://pi.dev/install.sh | sh
  Documentation: https://pi.dev

  */


  #### ---------------------------------------------------------
  ####  Developer tools for agentic coding
  #### ---------------------------------------------------------
  environment.systemPackages = with pkgs; [
    ollama
    opencode
    python3
    nodejs
  ];
  
  programs.npm = {
    enable = true; 
    package = pkgs.nodejs;
  };

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

