{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
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

          ###### Variables
          pool_datasets=(nas_data_primary)

          chown_owner="root:root"
          chmod_dir_options="750"
          chmod_file_options="640"

          zfs_share_options="rw=@192.168.1.0/24,root_squash"

          ##### Top level dataset options #####
          for pool_dataset in ''${pool_datasets[@]}; do
              echo "Setting top level dataset options for \"''${pool_dataset}\" pool"

              # Enable ACL (nfs4 type didn't work, couldn't set acl perms)
              zfs set acltype=posix "''${pool_dataset}"

              # Set non-acl owner
              chown -R "''${chown_owner}" "/''${pool_dataset}"

              # Set non-acl directory and file permissions
              find "/''${pool_dataset}" -type d -exec chmod ''${chmod_dir_options} "{}" \;
              find "/''${pool_dataset}" -type f -exec chmod ''${chmod_file_options} "{}" \;
          done

          ##### Dataset acl config #####
          ### nas_data_primary ###
          # ad
          echo "Setting acl for nas_data_primary/ad dataset"
          setfacl -R \
            -m "g:nas-caperren:rwx" \
            -m "g:nas-ad-management:rwx" \
            -m "g:nas-ad-view:rx" \
            /nas_data_primary/ad
          setfacl -R -d \
            -m "g:nas-caperren:rwx" \
            -m "g:nas-ad-management:rwx" \
            -m "g:nas-ad-view:rx" \
            /nas_data_primary/ad

          # caperren
          echo "Setting acl for nas_data_primary/caperren dataset"
          setfacl -R \
            -m "g:nas-caperren:rwx" \
            /nas_data_primary/caperren
          setfacl -R -d \
            -m "g:nas-caperren:rwx" \
            /nas_data_primary/caperren

          # caperren_gdrive

          # immich

          # kavita

          # long_term_storage

          # media
          echo "Setting acl for nas_data_primary/media dataset"
          setfacl -R \
            -m "g:nas-caperren:rwx" \
            -m "g:nas-media-management:rwx" \
            -m "g:nas-media-view:rx" \
            /nas_data_primary/media
          setfacl -R -d \
            -m "g:nas-caperren:rwx" \
            -m "g:nas-media-management:rwx" \
            -m "g:nas-media-view:rx" \
            /nas_data_primary/media

          ##### Set sharing options
          echo "Setting zfs sharing options for datasets"
          zfs set sharenfs="''${zfs_share_options}" nas_data_primary/ad
          zfs set sharenfs="''${zfs_share_options}" nas_data_primary/caperren
          zfs set sharenfs="''${zfs_share_options}" nas_data_primary/media
        ''}";

      };

      path = with pkgs; [
        acl
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
