{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/apollo-admin/apollo-admin.nix

    # System Configuration
    ../../modules/system/cpu-intel.nix
    ../../modules/system/fonts.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/security.nix
    ../../modules/system/systemd-boot.nix

    # Application Groups
    ../../modules/application-groups/system-utilities-cluster.nix
    ../../modules/application-groups/virtualization.nix
  ];

  networking.hostName = "cap-apollo-n01";


}
