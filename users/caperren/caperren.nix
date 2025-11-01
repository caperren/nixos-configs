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
      settings.user = {
        name = "Corwin Perren";
        email = "caperren@gmail.com";
      };

    };
    programs.bash.enable = true;
    programs.bemenu.enable = true;

    programs.kitty = {
      font.name = "JetBrains Mono";
    };

    # Assets
    home.file.".config/streamdeck-ui/icons".source = ./dotfiles/streamdeck/icons;

    # Application config files
    home.file.".config/glances/glances.conf".source = ./dotfiles/.config/glances/glances.conf;
    home.file.".config/hypr/hypridle.conf".source = ./dotfiles/hypridle/hypridle.conf;
    home.file.".config/hypr/hyprpaper.conf".source = ./dotfiles/hyprpaper/hyprpaper.conf;
    home.file.".config/hypr/backgrounds/black.png".source = ./dotfiles/hyprpaper/backgrounds/black.png;
    home.file.".config/hypr/hyprland-common.conf".source = ./dotfiles/hyprland/hyprland-common.conf;
    home.file.".config/hypr/hyprland.conf".source = hyprlandConfigPath + "/hyprland.conf";
    home.file.".config/kanshi/config".source = kanshiConfigPath + "/config";
    home.file.".config/streamdeck-ui/.streamdeck_ui_link.json" = {
      source = ./dotfiles/streamdeck/.streamdeck_ui.json;
      # Copy the symlinked version to its final location, otherwise it has no write permissions
      # on the config file, which breaks the entire app
      onChange = ''
        cat ~/.config/streamdeck-ui/.streamdeck_ui_link.json > ~/.streamdeck_ui.json
        chmod 600 ~/.streamdeck_ui.json
      '';
      force = true;
    };
    home.file.".config/spotify-player/app.toml".text = spotifyPlayerAppTomlText;
    home.file.".config/waybar/config".source = waybarConfigPath + "/config";
    home.file.".config/waybar/style.css".source = ./dotfiles/waybar/style.css;
    home.file.".config/wlogout/layout".source = ./dotfiles/wlogout/layout;

    # Desktop entry files so bemenu can find them
    home.file.".local/share/glava.desktop".source = ./dotfiles/.local/share/glava.desktop;
    home.file.".local/share/jetbrains-toolbox.desktop".source =
      ./dotfiles/.local/share/jetbrains-toolbox.desktop;
    home.file.".local/share/spotify-player.desktop".source =
      ./dotfiles/.local/share/spotify-player.desktop;

    # Custom bash aliases
    home.shellAliases = {
        # Streamdeck isn't easy to manually edit, so make a save command to copy any updates to the repo
        savestreamdeck = "cp ~/.streamdeck_ui.json ~/.nixos-configs/users/caperren/dotfiles/streamdeck/.streamdeck_ui.json";
    };

    # Theming
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

      font.name = "JetBrains Mono 11";
    };

    home.sessionVariables = {
      GTK_THEME = "Adwaita-dark";
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "okularApplication_pdf.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "image/*" = [ "imv.desktop" ];
      };
    };

    xresources.properties = {
      "Xft.font" = "JetBrains Mono";
    };
  };
}
