{ config, pkgs, ... }:

{
  imports = [
    # Users
    ../../users/cluster-admin/cluster-admin.nix

    # System Configuration
    ../system/cpu-amd.nix
    ../system/fonts.nix
    ../system/git-auto-rebuild.nix
    ../system/gpu-amd.nix
    ../system/home-manager-settings.nix
    ../system/internationalization.nix
    ../system/networking.nix
    ../system/nix-settings.nix
    ../system/security.nix
    ../system/server.nix
    ../system/ssd.nix
    ../system/systemd-boot.nix

    # Application Groups
    ../application-groups/k3s.nix
    ../application-groups/system-utilities-cluster.nix
  ];

  time.timeZone = "America/Los_Angeles";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
