{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/all-users.nix
    ../../users/apollo-admin/apollo-admin-home-manager.nix

    # System Configuration
    ../../modules/system/cpu-intel.nix
    ../../modules/system/fonts.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/hpe-ilo-fans.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/security.nix
    ../../modules/system/server.nix
    ../../modules/system/ssd.nix
    ../../modules/system/systemd-boot.nix
    ../../modules/system/zfs.nix

    # Application Groups
    ../../modules/application-groups/system-utilities-cluster.nix
    ../../modules/application-groups/virtualization.nix
  ];

  networking.hostName = "cap-apollo-n01";
  networking.hostId = "6169cc38";

  boot.zfs.extraPools = [
    #    "nas_data_homelab"
    "nas_data_primary"
    "nas_data_important"
  ];

  services.nfs.server.enable = true;

  # Set post-boot zfs options that aren't declarative through nixos directly
  systemd = {
    services.set-zfs-options = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "Sets zfs options post-boot";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "set-zfs-options.sh" ''
          set -e

          zfs set sharenfs="rw=@192.168.1.0/24" nas_data_primary/Media
          zfs set sharenfs=off nas_data_primary/Corwin
        ''}";

      };

      path = with pkgs; [
        zfs
        coreutils
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
