{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    audacity
    darktable
    inkscape
    # kdePackages.kdenlive  # <- Build Failure
    obs-studio
    pinta
  ];
}
