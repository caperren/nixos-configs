# nixos-configs

## Miscellaneous Notes
- To generate the sops age key for a new host
  - `nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'`
- Update keys after adding new host or personal key
  - `sops updatekeys <file>`
- To get the hashes for an updated version of a docker image
  - `nix-shell -p nix-prefetch-docker --run "nix-prefetch-docker --image-name <replace> --image-tag <replace>"`
- To generate a unique id for networking.hostId when using zfs
  - `head -c 8 /etc/machine-id`
## Misc references used
* https://github.com/XNM1/linux-nixos-hyprland-config-dotfiles/tree/main
  * For general flake-based layout of individual systems and layout
* https://github.com/rorosen/k3s-nix/tree/main
  * For kubernetes template within nixos framework
