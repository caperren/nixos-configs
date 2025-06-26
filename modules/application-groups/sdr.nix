{ config, pkgs, ... }:
{
  hardware.rtl-sdr.enable = true;

  environment.systemPackages = with pkgs; [
    soapysdr
    soapyrtlsdr
  ];

}
