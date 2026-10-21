{ pkgs, lib, ... }:

# Gigahost server agent (Flux monitoring), nix-ified version of:
#   wget -N https://flux.gigahost.no/static/installer.sh && bash installer.sh <serverkey>
#
# The upstream installer cannot run on NixOS: it resets PATH to FHS locations
# (where NixOS keeps almost nothing), installs packages with apt/dnf/yum/...,
# and relies on cron, useradd and groupadd. This module reproduces what the
# installer does, declaratively.
let
  # Tools the upstream agent.sh calls. The upstream script hard-codes an FHS
  # PATH (which does not exist on NixOS), so agent.sh is fetched below and
  # that line is rewritten to point at these packages instead.
  agentTools = with pkgs; [
    bash
    coreutils    # cat, tr, df, who, date, uname, sleep, head, tail
    gawk         # awk
    gnugrep      # grep
    gnused       # sed
    procps       # ps
    util-linux   # flock, lscpu
    iproute2     # ip, ss
    iputils      # ping
    jq
    curl
    inetutils    # hostname (keep last: it also ships ping/ifconfig)
  ];

  # Upstream agent, pinned by hash. If Gigahost updates agent.sh, the build
  # fails with a hash mismatch -- update `hash` to follow upstream.
  agentScript =
    pkgs.runCommand "gigahost-agent.sh" { } ''
      sed "s|^PATH=.*|PATH=${lib.makeBinPath agentTools}|" ${
        pkgs.fetchurl {
          url = "https://flux.gigahost.no/static/agent.sh";
          hash = "sha256-yPK9SZ9FxyFS8nmZerhSfjus2jCZcGoG0OXjcbkOyaU=";
        }
      } > $out
      chmod 0555 $out
    '';

  gateway = pkgs.writeText "gigahost-gateway" "https://api.gigahost.no/v0/monitor\n";
in
{
  # System user the agent runs as (the upstream installer does `useradd -r ghagent`).
  users.groups.ghagent = { };
  users.users.ghagent = {
    isSystemUser = true;
    group = "ghagent";
    home = "/opt/gigahost";
    description = "Gigahost server agent";
  };

  # /opt/gigahost layout, mirroring the upstream installer.
  # serverkey is deliberately not managed by Nix; create it once with:
  #   sudo sh -c 'echo <serverkey> > /opt/gigahost/serverkey && chown ghagent:ghagent /opt/gigahost/serverkey && chmod 0640 /opt/gigahost/serverkey'
  systemd.tmpfiles.rules = [
    "d /opt/gigahost 0750 ghagent ghagent -"
    "L+ /opt/gigahost/agent.sh - - - - ${agentScript}"
    "L+ /opt/gigahost/gateway - - - - ${gateway}"
  ];

  # Runs the agent every minute as ghagent. Replaces the upstream crontab line:
  #   * * * * * bash /opt/gigahost/agent.sh > /opt/gigahost/cron.log 2>&1
  # Output goes to the journal: journalctl -u gigahost-agent.service
  systemd.services.gigahost-agent = {
    serviceConfig = {
      Type = "oneshot";
      User = "ghagent";
      Group = "ghagent";
      WorkingDirectory = "/opt/gigahost";
      ExecStart = "${pkgs.bash}/bin/bash /opt/gigahost/agent.sh";
      # NoNewPrivileges is intentionally off: iputils ping is setuid/setcap and
      # needs its file capability to open raw sockets as the unprivileged ghagent user.
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = "/opt/gigahost";
    };
  };

  systemd.timers.gigahost-agent = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      AccuracySec = "1s";
    };
  };
}
