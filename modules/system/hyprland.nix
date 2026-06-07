{ config, pkgs, ... }:
{

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.hyprlock.enable = true;
  programs.waybar.enable = true;

  services.displayManager.ly = {
    enable = true;
#    x11Support = true;
    settings = {
      animation = "matrix";
      bg = 0;  # Black
      blank_password = true;
      border_fg = 3;  # Green
      clock = "%Y-%m-%d %H:%M:%S";
      fg = 3;  # Green
      hide_key_hints = true;
    };
  };

  services.hypridle.enable = true;
  services.xserver.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  environment.systemPackages = with pkgs; [
    arandr
    bemenu
    dunst
    # durdraw  # Maybe in the future....
    grim
    hyprpaper
    hyprpicker
    j4-dmenu-desktop
    kanshi
    libnotify
    mako
    nwg-look
    rofi
    slurp
    swayimg
    tuigreet
    wl-clipboard
    wlogout
  ];
}
