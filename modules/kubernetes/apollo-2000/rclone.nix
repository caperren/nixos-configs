{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageConfig = {
    imageName = "docker.io/rclone/rclone";
    imageDigest = "sha256:c08f5e100e1c4fa4deb1315b56a47c0cc0e765222b7c0834bc93305f2e4d85c0";
    hash = "sha256-d3lG/m8Hvkbm7Wp+fDQnztPHKCvvpitp7Uy+wCprjsg=";
    finalImageName = "docker.io/rclone/rclone";
    finalImageTag = "1.73.1";
  };
  image = pkgs.dockerTools.pullImage imageConfig // {
    arch = "amd64";
  };

  allowedReplicas = if config."perren.cloud".maintenance.nfs then 0 else 1;
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
    images = [ image ];
    manifests = {
      rclone-cronjob.content = {
        apiVersion = "batch/v1";
        kind = "CronJob";
        metadata = {
          name = "rclone";
          labels."app.kubernetes.io/name" = "rclone";
        };
        spec = {
          schedule = "0 0 * * *"; # Run at midnight every day of the week
          concurrencyPolicy = "Forbid";
          successfulJobsHistoryLimit = 3;
          failedJobsHistoryLimit = 3;

          jobTemplate.spec = {
            ttlSecondsAfterFinished = 3600; # Deletes jobs and pods 1hr after completion

            template = {
              metadata = {
                labels."app.kubernetes.io/name" = "rclone";
                annotations = {
                  "diun.enable" = "true";
                  "diun.watch_repo" = "true";
                  "diun.sort_tags" = "semver";
                  "diun.max_tags" = "5";
                  "diun.include_tags" = "${imageConfig.finalImageTag};^[0-9]*.[0-9]*.[0-9]*$";
                };
              };
              spec = {
                restartPolicy = "Never"; # rclone container will terminate when finished

                securityContext = {
                  runAsUser = 0;
                  runAsGroup = 0;
                  supplementalGroups = [ config.users.groups.nas-rclone-management.gid ];
                };

                containers = [
                  {
                    name = "rclone";
                    image = "${image.imageName}:${image.imageTag}";
                    imagePullPolicy = "IfNotPresent";
                    env = [
                      {
                        name = "TZ";
                        value = "America/Los_Angeles";
                      }
                    ];
                    command = [
                      "/bin/sh"
                      "-lc"
                    ];
                    args = [
                      ''
                        set -euo pipefail

                        mkdir -p /storage/google_drive

                        rclone sync "google_drive:" "/storage/google_drive" \
                          --drive-export-formats "ods,odt,odp" \
                          --create-empty-src-dirs \
                          --fast-list \
                          --checkers 16 \
                          --transfers 8 \
                          --retries 5 \
                          --retries-sleep 10s \
                          --stats 30s \
                          --log-level INFO
                      ''
                    ];
                    volumeMounts = [
                      {
                        mountPath = "/config";
                        name = "config";
                      }
                      {
                        mountPath = "/storage";
                        name = "storage";
                      }
                    ];
                  }
                ];
                volumes = [
                  {
                    name = "config";
                    persistentVolumeClaim.claimName = "rclone-config-pvc";
                  }
                  {
                    name = "storage";
                    persistentVolumeClaim.claimName = "rclone-storage-pvc";
                  }
                ];
              };
            };
          };
        };
      };
      rclone-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "rclone-config-pvc";
          labels = {
            "app.kubernetes.io/name" = "rclone";
            "recurring-job.longhorn.io/source" = "enabled";
            "recurring-job.longhorn.io/backup-daily" = "enabled";
          };
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "10Mi";
        };
      };
      rclone-storage-nfs-pv.content = {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "rclone-storage-nfs-pv";
          labels."app.kubernetes.io/name" = "jellyfin";
        };
        spec = {
          capacity.storage = "1Ti";
          accessModes = [ "ReadOnlyMany" ];
          persistentVolumeReclaimPolicy = "Retain";
          mountOptions = [
            "nfsvers=4.1"
            "rsize=1048576"
            "wsize=1048576"
            "hard"
            "timeo=600"
            "retrans=2"
          ];
          nfs = {
            server = "cap-apollo-n01";
            path = "/nas_data_primary/rclone";
          };
        };
      };
      rclone-storage-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "rclone-storage-pvc";
          labels."app.kubernetes.io/name" = "jellyfin";
        };
        spec = {
          selector.matchLabels."app.kubernetes.io/name" = "jellyfin";
          accessModes = [ "ReadOnlyMany" ];
          volumeName = "rclone-storage-nfs-pv";
          storageClassName = "";
          resources.requests.storage = "1Ti";
        };
      };
    };
  };
}
