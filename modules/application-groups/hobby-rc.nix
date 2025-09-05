{ config, pkgs, ... }:
{
  programs.qgroundcontrol.enable = true;

  environment.systemPackages = with pkgs; [
    mission-planner
  ];

}
