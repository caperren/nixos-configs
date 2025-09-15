{ config, pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  services.xserver = {
    enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  programs.hyprlock.enable = true;
  programs.waybar.enable = true;
  services.hypridle.enable = true;

  environment.systemPackages = with pkgs; [
    arandr
    dunst
    flameshot
    grim
    hyprpaper
    hyprpicker
    kanshi
    libnotify
    mako
    nwg-look
    rofi
    slurp
    swayimg
    wl-clipboard
    wlogout
    wofi
  ];

}
