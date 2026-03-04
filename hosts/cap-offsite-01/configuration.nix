{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/offsite-admin/offsite-admin-home-manager.nix

    # System Configuration
    ../../modules/system/fonts.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/security.nix
    ../../modules/system/server.nix
    ../../modules/system/ssd.nix
    ../../modules/system/systemd-boot.nix
    ../../modules/system/zfs.nix

    # Application Groups
    ../../modules/application-groups/system-utilities.nix

  ];

  boot.loader.systemd-boot.graceful = true;

  networking.hostName = "cap-offsite-01";
  networking.hostId = "c5d7ab9f";

  time.timeZone = "America/Los_Angeles";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
