{ config, pkgs, ... }:
{
  # Support steam hardware like the index and steam controller
  hardware.steam-hardware.enable = true;

  # Steam program itself
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Valve's micro-compositor
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Open source OpenXR runtime for VR
  services.monado = {
    enable = true;
    defaultRuntime = true;
    highPriority = true;
  };

}
