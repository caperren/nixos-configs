{ config, pkgs, ... }:
let
  hyprlandConfigPath = ./. + "/dotfiles/hyprland/${config.networking.hostName}";
  kanshiConfigPath = ./. + "/dotfiles/kanshi/${config.networking.hostName}";
  spotifyPlayerAppTomlTextTemplate = builtins.readFile ./dotfiles/spotify-player/app.toml;
  spotifyPlayerAppTomlText =
    builtins.replaceStrings [ "{{hostname}}" ] [ config.networking.hostName ]
      spotifyPlayerAppTomlTextTemplate;
  waybarConfigPath = ./. + "/dotfiles/waybar/${config.networking.hostName}";
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

    home.file.".config/hypr/hypridle.conf".source = ./dotfiles/hypridle/hypridle.conf;
    home.file.".config/hypr/hyprland-common.conf".source = ./dotfiles/hyprland/hyprland-common.conf;
    home.file.".config/hypr/hyprland.conf".source = hyprlandConfigPath + "/hyprland.conf";
    home.file.".config/kanshi/config".source = kanshiConfigPath + "/config";
    home.file.".config/spotify-player/app.toml".text = spotifyPlayerAppTomlText;
    home.file.".config/waybar/config".source = waybarConfigPath + "/config";
    home.file.".config/wlogout/layout".source = ./dotfiles/wlogout/layout;

    gtk = {
      enable = true;

      theme = {
        name = "Adwaita-dark"; # Or another dark theme
        package = pkgs.gnome-themes-extra;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      cursorTheme = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
      };
    };

    home.sessionVariables = {
      GTK_THEME = "Adwaita-dark";
    };
  };
}
