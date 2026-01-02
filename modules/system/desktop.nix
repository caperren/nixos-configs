{ config, pkgs, ... }:
{
  imports = [
    ./common.nix
  ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  services.blueman.enable = true; # Enables bluetooth manager
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
}
