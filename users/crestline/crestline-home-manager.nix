{ config, pkgs, ... }:
{
  users.users.crestline = {
    isNormalUser = true;
    description = "Crestline";
    extraGroups = [
      "dialout"
      "input"
      "nas-media-view"
      "networkmanager"
      "wheel"
    ];
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "crestline";
  };
  services.xserver.displayManager.gdm.autoLogin.delay = 60;

  home-manager.users.crestline = {
    home.username = "crestline";
    home.homeDirectory = "/home/crestline";
    home.stateVersion = "25.05";
  };
}
