{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/caperren/caperren.nix

    # System Configuration
    ../system/cpu-intel.nix
    ../system/fonts.nix
    ../system/home-manager-settings.nix
    ../system/internationalization.nix
    ../system/networking.nix
    ../system/nix-settings.nix
    ../system/security.nix
    ../system/systemd-boot.nix

    # Application Groups
    ../application-groups/system-utilities-cluster.nix
  ];

  networking.hostName = "cap-apollo-n01";
}
