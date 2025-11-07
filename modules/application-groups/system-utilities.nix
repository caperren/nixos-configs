{ config, pkgs, ... }:
{
  hardware.keyboard.qmk.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  programs.ydotool.enable = true;

  services.glances.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.hardware.openrgb.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;
  services.tumbler.enable = true; # Thumbnail support for images

  environment.systemPackages = with pkgs; [
    btop-cuda
    desktop-file-utils
    dnsutils
    ffmpeg-full
    git
    gparted
    htop
    iftop
    imagemagick
    iotop
    jq
    kdePackages.qt6ct
    killall
    kitty
    swappy
    lf
    minicom
    ncdu
    networkmanager
    networkmanagerapplet
    nmap
    nvtopPackages.full
    openrgb-with-all-plugins
    pciutils
    rofi-bluetooth
    # rpi-imager # <- Build Failure
    rpiboot
    s-tui
    scrcpy
    speedcrunch
    streamdeck-ui
    stress
    unzip
    usbutils
    util-linux
    wget
    xev
    xfce.mousepad
  ];

}
