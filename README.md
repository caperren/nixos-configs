# nixos-configs

## Miscellaneous Notes
- To generate the sops age key for a new host
  - `nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'`
- Update keys after adding new host or personal key
  - `sops updatekeys <file>`
## Misc references used
* https://github.com/XNM1/linux-nixos-hyprland-config-dotfiles/tree/main
