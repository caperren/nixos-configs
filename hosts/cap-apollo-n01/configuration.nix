{ config, pkgs, ... }:
let
  resticBackupStagingPath = "/run/restic-backup";
  resticBackupServicePrePostScript = pkgs.writeShellScript "restic-backup-pre-post" ''
    set -euo pipefail

    # Make sure staging path exists, and exit immediately if we just created it
    if [ -d "${resticBackupStagingPath}" ]; then
        mkdir -p ${resticBackupStagingPath}
        exit 0
    fi



  '';
in
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

  sops = {
    secrets = {
      "backups/primary/repository".sopsFile = ../../secrets/default.yaml;
      "backups/primary/id".sopsFile = ../../secrets/default.yaml;
      "backups/primary/key".sopsFile = ../../secrets/default.yaml;
      "${config.networking.hostName}/backups/restic-password".sopsFile = ../../secrets/apollo-2000.yaml;

      "${config.networking.hostName}/syncthing/cert.pem" = {
        owner = config.services.syncthing.user;
        sopsFile = ../../secrets/apollo-2000.yaml;
      };
      "${config.networking.hostName}/syncthing/key.pem" = {
        owner = config.services.syncthing.user;
        sopsFile = ../../secrets/apollo-2000.yaml;
      };
      "syncthing/gui-password" = {
        owner = config.services.syncthing.user;
        sopsFile = ../../secrets/default.yaml;
      };
    };

    templates.restic-backup-service-environment-file = {
      content = ''
        AWS_ACCESS_KEY_ID="${config.sops.placeholder."backups/primary/id"}"
        AWS_SECRET_ACCESS_KEY="${config.sops.placeholder."backups/primary/key"}"

        RESTIC_REPOSITORY="${
          config.sops.placeholder."backups/primary/repository"
        }/${config.networking.hostName}"
        RESTIC_PASSWORD="${config.sops.placeholder."${config.networking.hostName}/backups/restic-password"}"
      '';
    };
  };

  boot.zfs.extraPools = [
    "nas_data_high_speed"
    "nas_data_important"
    "nas_data_primary"
  ];

  # ZFS snapshot and replication management
  services.sanoid.datasets = {
    "nas_data_high_speed/ollama".useTemplate = [ "low_priority" ];
    "nas_data_primary/ad".useTemplate = [ "low_priority" ];
    "nas_data_primary/caperren".useTemplate = [ "medium_priority" ];
    "nas_data_primary/immich".useTemplate = [ "high_priority" ];
    "nas_data_primary/komga".useTemplate = [ "low_priority" ];
    "nas_data_primary/long_term_storage".useTemplate = [ "low_priority" ];
    "nas_data_primary/longhorn".useTemplate = [ "medium_priority" ];
    "nas_data_primary/media".useTemplate = [ "low_priority" ];
    "nas_data_primary/rclone".useTemplate = [ "medium_priority" ];
  };

  # Backup management
  #  services.restic.backups = {
  #    "nas_data_primary-caperren" = {
  #      environmentFile = config.sops.templates."restic-backup-service-environment-file".path;
  #      exclude = [ "" ];
  #    };
  #  };
  #  environment.systemPackages = [ pkgs.restic ];
  #  systemd.services.restic-backup = {
  #    serviceConfig = {
  #      Type = "oneshot";
  #      EnvironmentFile = config.sops.templates."restic-backup-service-environment-file".path;
  #      ExecStartPre = resticBackupServicePrePostScript;
  #      ExecStart = pkgs.writeShellScript "restic-backup" ''
  #        set -euo pipefail
  #      '';
  #      ExecStartPost = resticBackupServicePrePostScript;
  #    };
  #    path = with pkgs; [
  #      coreutils
  #      restic
  #    ];
  #  };

  # NFS for acting as a nas
  services.nfs.server.enable = true;

  # Syncthing for special apps like obsidian
  # https://wiki.nixos.org/wiki/Syncthing
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
    guiPasswordFile = config.sops.secrets."syncthing/gui-password".path;
    cert = config.sops.secrets."${config.networking.hostName}/syncthing/cert.pem".path;
    key = config.sops.secrets."${config.networking.hostName}/syncthing/key.pem".path;
    settings = {
      gui.user = "caperren";
      folders = {
        "obsidian" = {
          path = "/nas_data_primary/obsidian";
        };
      };
    };
  };

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
          pool_datasets=(nas_data_primary nas_data_high_speed)

          chown_owner="root:root"
          chmod_dir_options="750"
          chmod_file_options="640"

          zfs_share_base_options="rw=@192.168.1.0/24"
          zfs_share_options="''${zfs_share_base_options},root_squash"

          ##### Top level dataset options #####
          for pool_dataset in ''${pool_datasets[@]}; do
              # Enable ACL (nfs4 type didn't work, couldn't set acl perms)
              echo "Setting acltype for \"''${pool_dataset}\" pool"
              zfs set acltype=posix "''${pool_dataset}"

              # Make snapshot directory hidden, for chown/chmod simplicity
              echo "Disable snapshot visibility for \"''${pool_dataset}\" pool"
              zfs set snapdir=hidden "''${pool_dataset}"

              # Set non-acl owner
              echo "Recursively chowning directories in \"''${pool_dataset}\" pool"
              chown -R "''${chown_owner}" "/''${pool_dataset}"

              # Set non-acl directory and file permissions
              echo "Recursively chmoding directories in \"''${pool_dataset}\" pool"
              find "/''${pool_dataset}" -type d -exec chmod ''${chmod_dir_options} "{}" \;
              echo "Recursively chmoding files in \"''${pool_dataset}\" pool"
              find "/''${pool_dataset}" -type f -exec chmod ''${chmod_file_options} "{}" \;
          done

          ##### Dataset acl config #####
          ### nas_data_high_speed ###
          # ollama
          echo "Setting acl for nas_data_high_speed/ollama dataset"
          setfacl -R \
            -m "g:nas-ollama-management:rwx" \
            /nas_data_high_speed/ollama
          setfacl -R -d \
            -m "g:nas-ollama-management:rwx" \
            /nas_data_high_speed/ollama

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

          # rclone
          echo "Setting acl for nas_data_primary/rclone dataset"
          setfacl -R \
            -m "g:nas-caperren:rwx" \
            -m "g:nas-rclone-management:rwx" \
            /nas_data_primary/rclone
          setfacl -R -d \
            -m "g:nas-caperren:rwx" \
            -m "g:nas-rclone-management:rwx" \
            /nas_data_primary/rclone

          # immich
          echo "Setting acl for nas_data_primary/immich dataset"
          setfacl -R \
            -m "g:nas-immich-management:rwx" \
            /nas_data_primary/immich
          setfacl -R -d \
            -m "g:nas-immich-management:rwx" \
            /nas_data_primary/immich

          # komga
          echo "Setting acl for nas_data_primary/komga dataset"
          setfacl -R \
            -m "g:nas-caperren:rwx" \
            -m "g:nas-komga-management:rwx" \
            -m "g:nas-komga-view:rx" \
            /nas_data_primary/komga
          setfacl -R -d \
            -m "g:nas-caperren:rwx" \
            -m "g:nas-komga-management:rwx" \
            -m "g:nas-komga-view:rx" \
            /nas_data_primary/komga

          # long_term_storage
          echo "Setting acl for nas_data_primary/long_term_storage dataset"
          setfacl -R \
            -m "g:nas-caperren:rwx" \
            /nas_data_primary/long_term_storage
          setfacl -R -d \
            -m "g:nas-caperren:rwx" \
            /nas_data_primary/long_term_storage

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

          ##### Top level dataset options #####
          for pool_dataset in ''${pool_datasets[@]}; do
              # Make snapshot directory visible, for backups
              echo "Re-enabling snapshot visibility for \"''${pool_dataset}\" pool"
              zfs set snapdir=visible "''${pool_dataset}"
          done

          ##### Set sharing options
          echo "Setting zfs sharing options for datasets"
          zfs set sharenfs="''${zfs_share_options}" nas_data_high_speed/ollama
          zfs set sharenfs="''${zfs_share_options}" nas_data_primary/ad
          zfs set sharenfs="''${zfs_share_options}" nas_data_primary/caperren
          zfs set sharenfs="''${zfs_share_options}" nas_data_primary/rclone
          zfs set sharenfs="''${zfs_share_options}" nas_data_primary/immich
          zfs set sharenfs="''${zfs_share_options}" nas_data_primary/komga
          zfs set sharenfs="''${zfs_share_options}" nas_data_primary/long_term_storage
          zfs set sharenfs="''${zfs_share_options}" nas_data_primary/media

          # Longhorn is special and literally recommends no_root_squash when connecting to an
          # nfs data store for backups in its faq troubleshooting...
          zfs set sharenfs="''${zfs_share_base_options},no_root_squash" nas_data_primary/longhorn
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
