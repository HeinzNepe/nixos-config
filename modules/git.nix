{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Fancier diffs
    delta
  ];

  # Configure git
  programs.git = {
    enable = true;
    
    # Use Delta for diffs
    config = {
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      merge.conflictStyle = "zdiff3";
      delta = {
        navigate = true;
        line-numbers = true;
        hyperlinks = true;
      };
    
      # Add user config 
      user.name = "Henrik Nepstad";
      user.email = "github@topheinz.com";

      # Allow for SSH signing
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/GitHub-SigningKey.pub";
      commit.gpgsign = true;
      tag.gpgsign = true;
    };

    
  };


}
