# nixos-config
This repository is a repo containing all of my nixOS configurations. 


Clone this repo,
```
git clone https://github.com/HeinzNepe/nixos-config.git
```


 then use the following command to initiate the flake
```
sudo nixos-rebuild switch --flake .#device
```

Where \#device is any of the following devices: 
- laptop
- desktop


## Updating the git remote
If you want to commit stuff from a device using SSH for auth, you have to update the repository remote with the following command:
```
git remote set-url origin git@github.com:HeinzNepe/nixos-config.git
```

(more coming later)
