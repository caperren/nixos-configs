{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord
    slack
    signal-desktop
    telegram-desktop
  ];
}
