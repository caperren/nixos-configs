{ config, pkgs, ... }:
{
  hardware.rtl-sdr.enable = true;

  environment.systemPackages = with pkgs; [
    chirp
    soapysdr
    soapyrtlsdr
  ];

}
