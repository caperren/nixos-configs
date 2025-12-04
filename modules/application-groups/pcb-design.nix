{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kicad
    pcb2gcode
  ];

}
