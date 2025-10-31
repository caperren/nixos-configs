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

  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  programs.bash.shellAliases = {
    # Nix rebuild, switch
    nrs = "bash -c \"cd /etc/nixos && sudo nixos-rebuild switch --flake .#$(hostname) ; exit\"";
    # with tracing
    tnrs = "bash -c \"cd /etc/nixos && sudo nixos-rebuild switch --show-trace --flake .#$(hostname) ; exit\"";


    # Nix flake update, rebuild, switch
    nus = "bash -c \"cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#$(hostname) ; exit\"";
    # with tracing
    tnus = "bash -c \"cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --show-trace --flake .#$(hostname) ; exit\"";

    # Special cleanup, needed when efi partition runs out of space. Deletes all but the last five generations.
    # Remember to make that partition bigger in the future...
    neficlean = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | head -n -5 | cut -d ' ' -f2 | xargs -I {} sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system {}";
  };
}
