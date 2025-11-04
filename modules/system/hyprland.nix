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

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.hypridle.enable = true;
  services.xserver.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  environment.systemPackages = with pkgs; [
    arandr
    dunst
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
    wl-clipboard
    wlogout
    bemenu
  ];

}
