{ config, pkgs, ... }:
{
  programs.qgroundcontrol.enable = true;

  environment.systemPackages = with pkgs; [
    betaflight-configurator
    mission-planner
  ];

}
