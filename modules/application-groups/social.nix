{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord
    slack
    telegram-desktop
  ];
}
