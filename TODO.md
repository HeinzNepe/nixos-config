Add foundational AI components.

## Desktop

Things i want to look into for the desktop host.

- Streamdeck
- Login manager (GDM replacement)
    - Plasma login manager
    - TUIgreet
- Remove discord as a service. Set it to autostart instead 
- https://github.com/DocBrown101/org.kde.plasma.nixos.channelstatus
- AI 
    - The initial foundation package for a coding agent (pi) has been created and committed to hosts/desktop/pi.nix. Next steps involve integrating specific tooling (`llama-bench`, `reth` agents, etc.) into this setup and testing model compatibility.
- Middle mouse button scrolling?
- Fix Windows boot entry (Copy EFI parition to the NixOS drive)
- Deep dive into display freeze

## NO-VPS-01

Things that need doing

- Try with DHCP set up instead of static address
- Migrate data
- Configure backups