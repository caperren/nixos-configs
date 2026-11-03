{ config, pkgs, ... }:
{
  hardware.rtl-sdr.enable = true;

  environment.systemPackages = with pkgs; [
    chirp
    rtl-ais
    soapysdr
    soapyrtlsdr
  ];

}
