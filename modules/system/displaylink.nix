{ config, pkgs, ... }:
{
  services.xserver.videoDrivers = [
    "displaylink"
    "modesetting"
  ];

}
