{ config, pkgs, ... }:
{
  users.users.crestline = {
    isNormalUser = true;
    description = "Crestline";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "dialout"
    ];
    packages = with pkgs; [ ];

  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "crestline";
  };

  services.xserver.displayManager.gdm.autoLogin.delay = 60;
}
