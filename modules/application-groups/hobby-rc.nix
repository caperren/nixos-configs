{ config, pkgs, ... }:
{
  programs.qgroundcontrol.enable = true;

  environment.systemPackages = with pkgs; [
    betaflight-configurator
    inav-configurator
    mission-planner
  ];
}
