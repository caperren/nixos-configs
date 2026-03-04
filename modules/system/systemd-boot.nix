{ pkgs, ... }:
{
  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      memtest86.enable = true;
      netbootxyz.enable = true;
      configurationLimit = 8;
    };
    efi.canTouchEfiVariables = true;
  };
}
