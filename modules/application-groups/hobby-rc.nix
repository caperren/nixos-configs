{ config, pkgs, ... }:
{
  programs.qgroundcontrol.enable = true;

  environment.systemPackages = with pkgs; [
    inav-configurator
    mission-planner
  ];
}
