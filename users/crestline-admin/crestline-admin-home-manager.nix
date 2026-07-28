{ config, pkgs, ... }:
{
  users.users.crestline-admin = {
    isNormalUser = true;
    description = "Crestline Admin";
    extraGroups = [
      "dialout"
      "input"
      "networkmanager"
      "wheel"
    ];
  };

  home-manager.users.crestline-admin = {
    home.username = "crestline-admin";
    home.homeDirectory = "/home/crestline-admin";
    home.stateVersion = "26.05";
  };
}
