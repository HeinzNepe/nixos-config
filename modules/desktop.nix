{ inputs, pkgs, system, ... }:

{

  imports =
    [ 
      # Enable greetd display manager
      #./options/greetd.nix
 
      # Enable sddm display manager
      #./options/sddm.nix
    ];

  # Enable the KDE Plasma Desktop Environment.
  # Enable Plasma 6
  services.desktopManager.plasma6.enable = true;


  # Enable gdm display manager
  services.displayManager.gdm.enable = true; 
  # Might break. Follow up on https://nixpk.gs/pr-tracker.html?pr=525968



  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
  };

  
}
