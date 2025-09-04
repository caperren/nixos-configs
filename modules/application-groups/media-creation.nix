{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    audacity
    darktable
    davinci-resolve
    inkscape
    kdePackages.kdenlive
    obs-studio
  ];
}
