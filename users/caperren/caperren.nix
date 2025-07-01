{ config, pkgs, ... }:
let
  kanshiConfigPath = ./. + "/dotfiles/kanshi/${config.networking.hostName}/config";
in
{
  users.users.caperren = {
    isNormalUser = true;
    description = "Corwin Perren";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "dialout"
      "plugdev"
      "adbusers"
    ];
  };

  home-manager.users.caperren = {
    home.username = "caperren";
    home.homeDirectory = "/home/caperren";
    home.stateVersion = "25.05";

    home.packages = with pkgs; [
      obsidian
    ];

    programs.git = {
      enable = true;
      userName = "Corwin Perren";
      userEmail = "caperren@gmail.com";
    };

    home.file.".config/kanshi/config".source = kanshiConfigPath;
    home.file.".config/wlogout/layout".source = ./dotfiles/wlogout/layout;
  };
}
