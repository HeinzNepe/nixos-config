{ config, lib, pkgs, ... }:

{
    services.mealie = {
        enable = true;
        port = 9925;
    };
}