{ config, pkgs, ... }:
{
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.evdi ];
    initrd = {
      # List of modules that are always loaded by the initrd.
      kernelModules = [
        "evdi"
      ];
    };
  };
  services.xserver.videoDrivers = [
    "displaylink"
    "modesetting"
  ];

}
