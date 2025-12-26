{ config, pkgs, lib, ... }:

{

  programs.git = {
    enable = true;
    settings = {
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
      commit = {
        gpgsign = true;
      };

      user = {
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKksxEesLt9PVO22kys14zWl92flBqDkTjHB/hy5Gpg3";
      };
    };
  };

}
