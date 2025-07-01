{ config, pkgs, ... }:
{
    home-manager.useGlobalPkgs = true;
    home-manager.backupFileExtension = "bkp";
}