{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gallery-dl
    transmission_4-qt
    yt-dlp
  ];
}
