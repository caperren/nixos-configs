{ config, pkgs, ... }:
{

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    btop
    dnsutils
    git
    htop
    iftop
    iotop
    jq
    killall
    kitty
    ncdu
    networkmanager
    nmap
    nvtopPackages.full
    pciutils
    screen
    unzip
    usbutils
    util-linux
    wget
    yq
  ];
}
