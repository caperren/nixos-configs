{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kicad
    pcb2gcode
    saleae-logic-2
  ];

}
