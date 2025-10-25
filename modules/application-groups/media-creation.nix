{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    audacity
    darktable
    inkscape
    kdePackages.kdenlive
    obs-studio
  ];
}
