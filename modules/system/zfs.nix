{ config, pkgs, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];

  services.zfs = {
    autoImport.enable = false;
    autoScrub.enable = true;
    trim.enable = true;
  };

  environment.systemPackages = with pkgs; [
    zfs
  ];
}
