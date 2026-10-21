# Gigahost Server Agent (Flux monitoring) on NixOS

How the Gigahost server agent is run on `no-gh-vps-01`, and why the upstream
installer cannot be used on NixOS.

The upstream install command is:

```bash
wget -N https://flux.gigahost.no/static/installer.sh && bash installer.sh <serverkey>
```

The server key is intentionally **not** stored in this document. It exists only
as `/opt/gigahost/serverkey` on the host (mode `0640`, owner `ghagent:ghagent`).

## Why the upstream installer fails on NixOS

`wget -N` is not the problem — `wget` is installed via `modules/cli-programs.nix`.
The failure is inside `installer.sh` (the "Gigahost Server Agent Installer"). It is
written for classic FHS distributions (Debian/RHEL/Arch/Alpine/Gentoo), and the
first thing it does (line 7) is:

```bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

On NixOS those directories are nearly empty (only `/bin/sh` and `/usr/bin/env`
exist); all tools live in `/run/current-system/sw/bin` and the nix profiles. The
consequences, in order:

1. **Root check misfires.** `[ "$(id -u)" != "0" ]` cannot find `id` (coreutils is
   not in the FHS paths), the substitution is empty, and the script exits 1 with
   `Gigahost Server Agent installer needs to be installed with root privileges` —
   even when run as root / with sudo. This is the failure you actually see.
2. **No package manager.** None of `yum`, `dnf`, `apt-get`, `pacman`, `zypper`,
   `apk`, `emerge` exist, so no dependencies get installed. The script has a NixOS
   branch (`nix-env -iA nixos.wget nixos.cron ...`), but it is dead code: the PATH
   reset hides `nix-env`, and `nix-env -iA nixos.*` requires the legacy `nixos`
   channel, which a flake-based install does not set up. It would not start a cron
   daemon either.
3. **No cron.** `crontab` is not present on NixOS by default, so the script exits 1
   with `Cron is required but we could not install it.`
4. **No useradd/groupadd.** NixOS has neither (users are declared in
   `configuration.nix`). The `ghagent` user/group would never be created (the
   errors are swallowed by `|| true`), so `chown -R ghagent:ghagent /opt/gigahost`
   and `crontab -u ghagent` would fail and no cron job would ever be installed.
5. **The agent itself repeats the mistake.** `agent.sh` hard-codes the same FHS
   `PATH=` line near its top (line 6), so even a successful install would leave an
   agent that cannot find `ip`, `jq`, `ping`, `flock`, `ps`, `hostname`, etc. when
   cron runs it.

## The nix-ified replacement

Files:

- `hosts/no-gh-vps-01/modules/gigahost-agent.nix` — the module (new)
- `hosts/no-gh-vps-01/configuration.nix` — imports `./modules/gigahost-agent.nix`

Mapping of upstream installer steps to NixOS options:

| Upstream installer step | NixOS replacement |
| --- | --- |
| `groupadd ghagent` / `useradd -r ghagent -d /opt/gigahost -s /bin/false` | `users.groups.ghagent` + `users.users.ghagent` (`isSystemUser = true`, home `/opt/gigahost`) |
| `mkdir -p /opt/gigahost`, `chmod -R 750` | `systemd.tmpfiles.rules`: `d /opt/gigahost 0750 ghagent ghagent -` |
| `curl -fsSL -o /opt/gigahost/agent.sh https://flux.gigahost.no/static/agent.sh` | `pkgs.fetchurl` pinned by sha256, exposed via tmpfiles `L+` symlink |
| hard-coded FHS `PATH=` line in `agent.sh` | rewritten at build time to the nix store bin paths of the tools the agent calls |
| `echo "$1" > /opt/gigahost/serverkey`, `chmod 640` | one-time manual command (see Deploy); deliberately not managed by Nix |
| `echo "https://api.gigahost.no/v0/monitor" > /opt/gigahost/gateway` | `pkgs.writeText` + tmpfiles `L+` symlink |
| `crontab -u ghagent`: `* * * * * bash /opt/gigahost/agent.sh > /opt/gigahost/cron.log 2>&1` | `systemd.timers.gigahost-agent` (every minute) + `systemd.services.gigahost-agent` (oneshot, `User=ghagent`) |
| dependency install (cron, curl, jq, iproute2, iputils, perl, unzip, ...) | `agentTools` list, injected into the patched `PATH` inside `agent.sh` |

### The one modification to the upstream script

`agent.sh` is fetched with `pkgs.fetchurl` (pinned) and passed through:

```bash
sed "s|^PATH=.*|PATH=<nix store bin paths>|"
```

The replacement PATH contains exactly the tools `agent.sh` calls:

- `bash`, `coreutils` (cat, tr, df, who, date, uname, sleep, head, tail)
- `gawk` (awk), `gnugrep` (grep), `gnused` (sed)
- `procps` (ps), `util-linux` (flock, lscpu)
- `iproute2` (ip, ss), `iputils` (ping)
- `jq`, `curl`
- `inetutils` (hostname — kept last in the list because it also ships `ping`/`ifconfig`)

Pinned upstream hash (fetched 2026-10-21, agent version `1.1`):

```
sha256-yPK9SZ9FxyFS8nmZerhSfjus2jCZcGoG0OXjcbkOyaU=
```

### Resulting `/opt/gigahost` layout

| Path | Kind | Notes |
| --- | --- | --- |
| `/opt/gigahost` | directory, `0750 ghagent:ghagent` | created by tmpfiles |
| `/opt/gigahost/agent.sh` | symlink into `/nix/store` | pinned upstream agent, PATH line patched |
| `/opt/gigahost/gateway` | symlink into `/nix/store` | contains `https://api.gigahost.no/v0/monitor` |
| `/opt/gigahost/serverkey` | real file, `0640 ghagent:ghagent` | created once manually, see Deploy |
| `/opt/gigahost/agent.lock` | real file | created by the agent at runtime (single-instance `flock`) |

`agent.sh` and `gateway` are symlinks into the nix store — never edit them in
place; change the module and rebuild.

### Scheduling and service hardening

The upstream crontab line is replaced by a systemd timer + oneshot service:

- `systemd.timers.gigahost-agent`: `OnBootSec=1min`, `OnUnitActiveSec=1min`,
  `AccuracySec=1s` — i.e. every minute, like `* * * * *`. The script's own
  `sleep $((RANDOM % 30))` jitter is preserved.
- `systemd.services.gigahost-agent`: `Type=oneshot`, `User=ghagent`,
  `Group=ghagent`, `WorkingDirectory=/opt/gigahost`,
  `ExecStart=${pkgs.bash}/bin/bash /opt/gigahost/agent.sh`.
- Hardening: `ProtectSystem=strict` + `ReadWritePaths=/opt/gigahost` (the agent
  only writes `agent.lock` there), `PrivateTmp=true`, `ProtectHome=true`.
- `NoNewPrivileges` is intentionally **off**: iputils `ping` is setuid/setcap and
  needs its file capability to open raw sockets as the unprivileged `ghagent`
  user. (Granting `AmbientCapabilities=CAP_NET_RAW` instead was considered and
  rejected as a broader grant.)
- Output goes to the journal (`journalctl -u gigahost-agent.service`) instead of
  the upstream `cron.log`.

### Runtime data flow

Every minute the service runs `agent.sh` as `ghagent`. The script sleeps a random
0–29 s (jitter), takes an `flock` on `/opt/gigahost/agent.lock` (single instance),
reads the serverkey and gateway URL from `/opt/gigahost`, collects host stats from
`/proc` (CPU, memory, disks, network interfaces, connections, ping latency, top
processes, ...), and POSTs a JSON payload to `https://api.gigahost.no/v0/monitor`.

## Deploy

```bash
# On the host, from a checkout of this repo:
sudo nixos-rebuild switch --flake .#no-gh-vps-01
# (or after pushing: sudo nixos-rebuild switch --flake github:heinznepe/nixos-config#no-gh-vps-01)

# Populate /opt/gigahost immediately (tmpfiles also runs at boot):
sudo systemd-tmpfiles --create

# One-time: write the server key (replace <serverkey>; not stored anywhere in git):
sudo sh -c 'echo <serverkey> > /opt/gigahost/serverkey && chown ghagent:ghagent /opt/gigahost/serverkey && chmod 0640 /opt/gigahost/serverkey'
```

## Verify

```bash
sudo systemctl start gigahost-agent.service   # run once immediately
systemctl status gigahost-agent.service       # exit status of the last run
systemctl list-timers gigahost-agent.timer    # next scheduled run
sudo journalctl -u gigahost-agent.service -n 20
```

The agent is silent on success (it `curl -s -o /dev/null`s the report), so an empty
journal means success. Confirm the host shows up / reports in your Gigahost
dashboard. The host firewall only restricts inbound traffic (22/80/443 TCP,
51820/21820 UDP on `ens18`); the outbound HTTPS to `api.gigahost.no` needs no
firewall change.

## Maintenance

- **Upstream agent update:** `agent.sh` is pinned by hash. When Gigahost updates
  it, the build fails with a hash mismatch that prints the new hash — update
  `hash` in `hosts/no-gh-vps-01/modules/gigahost-agent.nix` and rebuild. The new
  `agent.sh` reaches `/opt/gigahost/agent.sh` via the tmpfiles `L+` rule (run
  `sudo systemd-tmpfiles --create` after switching, or reboot).
- **Rotate the server key:** rewrite `/opt/gigahost/serverkey` with the Deploy
  command above. No rebuild or restart needed — the agent reads it on every run.
- **Logs:** `sudo journalctl -u gigahost-agent.service` (the upstream `cron.log`
  redirect is replaced by the journal).
- **Removal:** delete the import in `configuration.nix`, rebuild (this removes the
  `ghagent` user, the timer and the service), then `sudo rm -rf /opt/gigahost`.

## Caveats / known differences from the upstream install

- `ssh_sessions` always reports `0`: NixOS does not maintain utmp, so `who` finds
  nothing. Everything else (including ping latency) works.
- `ping` works because nixpkgs ships it setuid/setcap and `NoNewPrivileges` is off
  (see above).
- The serverkey is a plain file on the host — not in git, not in the nix store.
  If you later want it declarative, the repo's sops pattern
  (`secrets/hosts/no-gh-vps-01.yml` + `sops.secrets`) drops into the module in a
  few lines.
- Pinning `agent.sh` means the agent no longer tracks upstream automatically; you
  update deliberately on hash mismatch.
- The agent reports whatever the pinned script reports; at the time of writing that
  is agent version `1.1`.
- The upstream installer deletes itself at the end (`rm -f "$0"`) and cleans up
  previous installs; neither is relevant for the nix-ified setup. If a previous
  manual attempt left files in `/opt/gigahost`, the tmpfiles `L+` rules replace
  `agent.sh`/`gateway` with symlinks and the `d` rule fixes directory ownership.
