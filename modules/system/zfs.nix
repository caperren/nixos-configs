{ config, pkgs, ... }:
{
    services.zfs = {
        enable = true;
        autoScrub = true;
        trim.enable = true;
    };
}
