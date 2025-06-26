{ config, pkgs, ... }:
{
  programs.adb.enable = true;
  virtualisation.waydroid.enable = true;
}
