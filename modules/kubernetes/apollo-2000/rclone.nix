{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageConfig = {
    imageName = "rclone/rclone";
    imageDigest = "sha256:9f59fda717a48aced38d7f27e9ec8fd9992b5651e7a03897bebf204d3a9197d6";
    hash = "sha256-V6NwkOkzCbdN8Me8jzQ/9VSDcAbYAJMNbtKCz6K+ROE=";
    finalImageName = "rclone/rclone";
    finalImageTag = "1.73.0";
  };
  image = pkgs.dockerTools.pullImage imageConfig // {
    arch = "amd64";
  };

  allowedReplicas = if config."perren.cloud".maintenance.nfs then 0 else 1;
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  sops = {
    secrets."rclone/config/google-drive-token".sopsFile = ../../../secrets/apollo-2000.yaml;

    templates.rclone-environment-secret = {
      content = builtins.toJSON {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "rclone-environment-secret";
          labels."app.kubernetes.io/name" = "rclone";
        };
        stringData.GOOGLE_DRIVE_TOKEN = config.sops.placeholder."rclone/config/google-drive-token";
      };
      path = "/var/lib/rancher/k3s/server/manifests/rclone-environment-secret.yaml";
    };
  };
  services.k3s = {
    images = [ image ];
    manifests = {
      rclone-config.content = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "rclone-configmap";
          labels."app.kubernetes.io/name" = "rclone";
        };
        data = {
          "rclone.conf" = ''
            [google_drive]
            type = drive
            scope = drive
            env_auth = true
            token_url = https://oauth2.googleapis.com/token
            client_id = YOUR_CLIENT_ID
            client_secret = YOUR_CLIENT_SECRET
          '';
        };
      };
      rclone-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "rclone";
          labels."app.kubernetes.io/name" = "rclone";
        };
        spec = {
          replicas = allowedReplicas;
          strategy = {
            type = "RollingUpdate";
            rollingUpdate = {
              maxSurge = 0;
              maxUnavailable = 1;
            };
          };

          selector.matchLabels."app.kubernetes.io/name" = "rclone";

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
              securityContext.supplementalGroups = [ config.users.groups.nas-caperren-gdrive-management.gid ];
              containers = [
                {
                  name = "rclone";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  envFrom = [ { secretRef.name = "rclone-environment-secret"; } ];
                  volumeMounts = [
                    {
                      mountPath = "/home/user/.config/rclone/rclone.conf";
                      name = "config";
                      subPath = "rclone.conf";
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
                  configMap.name = "rclone-configmap";
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
