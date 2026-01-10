# nixos-configs

## Miscellaneous Notes

- Nix-debugging tools
    - `nix repl`
        - `:?` -> internal help command
        - `:p <any nix expression>` -> bypass lazy eval (if you get "..." prints)
        - `:lf <file>` -> load a flake file into scope
        - `:lf nixpkgs` -> load all packages into scope
        - `:doc <expr | path>` -> show relevant docs
    - `nixos-rebuild repl --flake <path>`
        - Loads a flake directly into nix repl, accessible under `flake.`
            - Special note that it doesn't evaluate anything by default, so you can use it to check configs for OTHER
              hosts, too!
        - `:r` -> reload the flake from disk for realtime editing/test dev loop
        - Examples
            - Print shell script created with `pkgs.writeShellScript` and linked to alias
                -
                `:p builtins.readFile flake.nixosConfigurations.cap-apollo-n01.config.programs.bash.shellAliases.setzfsoptions`
    - `nix-inspect --expr 'builtins.getFlake "<path>"'`
        - Shows flake in `lf`-style hierarchical interface
- To generate the sops age key for a new host
    - `nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'`
- Update keys after adding new host or personal key
    - `sops updatekeys <file>`
- To get the hashes for an updated version of a docker image
    - `nix-shell -p nix-prefetch-docker --run "nix-prefetch-docker --image-name <replace> --image-tag <replace>"`
- To generate a unique id for networking.hostId when using zfs
    - `head -c 8 /etc/machine-id`
- Watch all container logs by deployment name
    - `kubectl logs -f -l app.kubernetes.io/name=<app name> --all-containers`
- To get a shell for a specific pod
    - `kubectl exec --stdin --tty <pod-name> -- <bash | sh>`
- To figure out why a manifest is not applying (after it's present)
    - `kubectl apply -f /var/lib/rancher/k3s/server/manifests/<manifest file>`
- Get logs for a particular container (like init containers) in a pod
    - `kubectl logs <pod name> -c <container name>`
- To get realtime zfs statistics
  - `zpool iostat -y 5`
- To drain a node of its pods, to allow for a reboot without service interruption
  - `kubectl cordon <node>`
    - Disables scheduling, so pods aren't re-assigned
  - `kubectl drain <node> --ignore-daemonsets`
    - Removes the pods from the node, leaving daemonsets that won't globally affect cluster operation
  - `kubectl get pods -A -owide`
    - Verify that nodes have moved
  - Perform reboot
  - `kubectl uncordon <node>`
    - After work is complete, to allow scheduling 

## Misc references used
* https://github.com/XNM1/linux-nixos-hyprland-config-dotfiles/tree/main
    * For general flake-based layout of individual systems and layout
* https://github.com/rorosen/k3s-nix/tree/main
    * For kubernetes template within nixos framework
* http://www.chriswarbo.net/projects/nixos/useful_hacks.html
  * Misc useful things like turning Nix lists into bash arrays

## Helpful videos

- https://www.youtube.com/watch?v=swiWnAwionc
