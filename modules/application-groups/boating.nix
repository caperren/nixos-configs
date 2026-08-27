{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    opencpn
  ];
}
