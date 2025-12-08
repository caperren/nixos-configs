{ config, pkgs, ... }:
{

  services.glances.enable = true;
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    btop
    dnsutils
    git
    htop
    iftop
    iotop
    killall
    kitty
    ncdu
    networkmanager
    nmap
    nvtopPackages.full
    pciutils
    unzip
    usbutils
    util-linux
    wget
    firefox
  ];
}
