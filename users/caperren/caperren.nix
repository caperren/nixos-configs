{ config, pkgs, ... }:
let
  hyprlandConfigPath = ./. + "/dotfiles/hyprland/${config.networking.hostName}";
  kanshiConfigPath = ./. + "/dotfiles/kanshi/${config.networking.hostName}";
  sshDesktopPubkey = builtins.readFile ./pubkeys/cap-nr200p.pub;
  sshLaptopPubkey = builtins.readFile ./pubkeys/cap-slim7.pub;
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
      "adbusers"
      "dialout"
      "docker"
      "input"
      "networkmanager"
      "plugdev"
      "podman"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
        sshDesktopPubkey
        sshLaptopPubkey
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
      enable = true;
      font.name = "JetBrains Mono";
      settings = {
        allow_remote_control = true;
      };
    };

    # Assets/scripts
    home.file.".config/streamdeck-ui/icons".source = ./dotfiles/streamdeck/icons;
    home.file.".config/hypr/scripts".source = ./dotfiles/.config/hypr/scripts;

    # Application config files
    home.file.".config/containers/policy.json".source = ./dotfiles/.config/containers/policy.json;
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
    home.file.".local/share/applications/alltop.desktop".source =
      ./dotfiles/.local/share/applications/alltop.desktop;
    home.file.".local/share/applications/glava.desktop".source =
      ./dotfiles/.local/share/applications/glava.desktop;
    home.file.".local/share/applications/phonerdp.desktop".source =
      ./dotfiles/.local/share/applications/phonerdp.desktop;
    home.file.".local/share/applications/spotify-player.desktop".source =
      ./dotfiles/.local/share/applications/spotify-player.desktop;

    # Custom bash aliases
    home.shellAliases = {
      # Phone remote desktop over usb (adb), with some default flags I want
      phonerdp = "scrcpy --no-audio --orientation=0 --turn-screen-off --stay-awake --power-off-on-close";

      # Streamdeck isn't easy to manually edit, so make a save command to copy any updates to the repo
      savestreamdeck = "cp ~/.streamdeck_ui.json ~/.nixos-configs/users/caperren/dotfiles/streamdeck/.streamdeck_ui.json";

      # Nice to have an alias if I ever want to launch this from cmdline, or see the dbus help string
      screenshot = "~/.config/hypr/scripts/screenshot.sh";
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

    home.sessionPath = [
      "$HOME/.local/share"
    ];
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
