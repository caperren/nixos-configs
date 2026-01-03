{ config, pkgs, ... }:
{
    services.zfs = {
        enable = true;
        autoScrub.enable = true;
        trim.enable = true;
    };
}
