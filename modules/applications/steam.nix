{ config, pkgs, ... }:
{
  hardware.steam-hardware.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

}
