{ config, pkgs, ... }:
{
  boot.zfs = {
    enabled = true;
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  environment.systemPackages = with pkgs; [
    zfs
  ];
}
