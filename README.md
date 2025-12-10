# My NixOS config
(more coming later)

## The repo
This repository is a repo containing all of my nixOS configurations.

### Cloning the repo
Clone this repo,
```
git clone https://github.com/HeinzNepe/nixos-config.git
```

### Updating the git remote
If you want to commit stuff from a device using SSH for auth, you have to update the repository remote with the following command:
```
git remote set-url origin git@github.com:HeinzNepe/nixos-config.git
```

## The flake
Use the following command to initiate the configuration using a nix flake
```
sudo nixos-rebuild switch --flake .#device
```

Where \#device is any of the following devices: 
- laptop
- desktop
- wsl

### Updating the flake
Updating the flake is done with
```
sudo nix flake update
```
