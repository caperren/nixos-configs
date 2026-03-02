{ config, pkgs, ... }:
{

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    btop
    dnsutils
    git
    htop
    iftop
    inetutils
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
    wireguard-tools
    yq
  ];
}
