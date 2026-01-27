{ config, pkgs, ... }:
{
  imports = [
    ../../users/all-groups.nix
    ../../users/root/root-home-manager.nix

    ./maintenance.nix
  ];

  # Statically generated groups for consistent nas sharing won't work otherwise
  users.mutableUsers = false;

  # For nfs client support
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  # For better overall system performance
  # Note that this should NOT be used on single-core systems, those which
  # use core pinning, those which disable cores, or where expected single-core
  # loads will be at or near 100%. For my systems, this is a non-issue and
  # should actually improve performance overall by distributing irq load.
  # Automatically will not run on single-core systems, and in containers.
  # https://github.com/NixOS/nixpkgs/issues/299477#issuecomment-2023125360
  services.irqbalance.enable = true;
}
