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
  services.hypridle.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    dunst
    libnotify
    rofi-wayland
    nwg-look
    nwg-displays
    slurp
    grim
    arandr
    wl-clipboard
    wlogout
    flameshot
    wofi
    swayimg
    hyprpicker
    kanshi
    mako

    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
  ];

}
