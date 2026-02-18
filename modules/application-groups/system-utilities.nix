{ config, pkgs, ... }:
{
  hardware.keyboard.qmk.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  programs.ssh.startAgent = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];

  # Yazi file manager, with substitute for pre-packaged version
  nix = {
    settings = {
      substitute = true;
      substituters = [
        "https://yazi.cachix.org"
      ];
      trusted-public-keys = [
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      ];
    };
  };
  programs.yazi.enable = true;

  programs.ydotool.enable = true;

  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.hardware.openrgb.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;
  services.tumbler.enable = true; # Thumbnail support for images

  environment.systemPackages = with pkgs; [
    btop-cuda
    desktop-file-utils
    dmidecode
    dnsutils
    ffmpeg-full
    git
    gparted
    htop
    iftop
    imagemagick
    iotop
    jq
    k3s
    kdePackages.qt6ct
    killall
    kitty
    swappy
    lf
    mesa-demos
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
    screen
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
