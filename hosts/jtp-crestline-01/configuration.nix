{ config, pkgs, ... }:

{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/crestline-admin/crestline-admin-home-manager.nix

    # System Configuration
    ../system/cpu-intel.nix
    ../system/fonts.nix
    ../system/home-manager-settings.nix
    ../system/internationalization.nix
    ../system/networking.nix
    ../system/nix-settings.nix
    ../system/security.nix
    ../system/server.nix
    ../system/ssd.nix
    ../system/systemd-boot.nix

    # Application Groups
    ../application-groups/system-utilities-cluster.nix
  ];

  networking.hostName = "jtp-crestline-01";

  time.timeZone = "America/Los_Angeles";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
