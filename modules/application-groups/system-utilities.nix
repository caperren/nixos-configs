{ config, pkgs, ... }:
{
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  programs.ydotool.enable = true;

  services.openssh.enable = true;
  services.printing.enable = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  hardware.keyboard.qmk.enable = true;

  services.hardware.openrgb.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    lf
    git
    htop
    iftop
    iotop
    util-linux
    usbutils
    dnsutils
    unzip
    killall
    wget
    jq
    speedcrunch
    gparted
    ffmpeg-full
    xfce.mousepad
    imagemagick
    nvtopPackages.full
    ncdu
    s-tui
    nmap
    pciutils
    desktop-file-utils
    rpi-imager
    rpiboot
    streamdeck-ui
    scrcpy
    openrgb-with-all-plugins
    networkmanagerapplet
    rofi-bluetooth
    networkmanager
  ];

}
