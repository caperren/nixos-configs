{ config, pkgs, ... }:
{
  # Note that this should NOT be used on single-core systems, those which
  # use core pinning, those which disable cores, or where expected single-core
  # loads will be at or near 100%. For my systems, this is a non-issue and
  # should actually improve performance overall by distributing irq load.
  # Automatically will not run on single-core systems, and in containers.
  # https://github.com/NixOS/nixpkgs/issues/299477#issuecomment-2023125360
  services.irqbalance.enable = true;
}
