{ config, pkgs, ... }:
{
  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Generally want a larger download buffer
  nix.settings.download-buffer-size = 524288000;

  programs.bash.shellAliases = {
    nixrebuild = "pushd /etc/nixos && { trap 'popd' EXIT; sudo nixos-rebuild switch --flake .#$(hostname); }";
    nixupdate = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#$(hostname)";
    nixedit = "sudo nano /etc/nixos/hosts/$(hostname)/configuration.nix";

    nixlimitfive = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | head -n -5 | cut -d ' ' -f2 | xargs -I {} sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system {}";
  };
}
