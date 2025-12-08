{ config, pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  nixpkgs.config.rocmSupport = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
}
