{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageConfig = {
    imageName = "stashapp/stash";
    imageDigest = "sha256:4cac18873ea052f03510602d9e1a9b29e6241a393a111479010292b7a1e28a5e";
    hash = "sha256-D3XMtByDotpCR/Q4CqoKzL1n/wGHgXMyPNYpkUxxlXs=";
    finalImageName = "stashapp/stash";
    finalImageTag = "v0.30.1";
  };
  image = pkgs.dockerTools.pullImage imageConfig // {
    arch = "amd64";
  };

  allowedReplicas = if config."perren.cloud".maintenance.nfs then 0 else 1;
  stashShareEnvironment = [
    {
      name = "TZ";
      value = "America/Los_Angeles";
    }
    {
      name = "STASH_STASH";
      value = "/data/";
    }
    {
      name = "STASH_GENERATED";
      value = "/store/generated/";
    }
    {
      name = "STASH_METADATA";
      value = "/store/metadata/";
    }
    {
      name = "STASH_CACHE";
      value = "/cache/";
    }
  ];
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    images = [ image ];
    manifests = {
      # A
      stash-a-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "stash-a";
          labels."app.kubernetes.io/name" = "stash-a";
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

          selector.matchLabels."app.kubernetes.io/name" = "stash-a";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "stash-a";
              annotations."diun.enable" = "true";
            };
            spec = {
              securityContext.supplementalGroups = [ config.users.groups.nas-ad-view.gid ];
              containers = [
                {
                  name = "stash-a";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  env = stashShareEnvironment;
                  ports = [ { containerPort = 9999; } ];
                  volumeMounts = [
                    {
                      mountPath = "/store";
                      name = "store";
                    }
                    {
                      mountPath = "/root/.stash";
                      name = "config";
                    }
                    {
                      mountPath = "/data";
                      name = "content";
                    }
                    {
                      mountPath = "/cache";
                      name = "cache";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "cache";
                  emptyDir = { };
                }
                {
                  name = "config";
                  persistentVolumeClaim.claimName = "stash-a-config-pvc";
                }
                {
                  name = "store";
                  persistentVolumeClaim.claimName = "stash-a-store-pvc";
                }
                {
                  name = "content";
                  persistentVolumeClaim.claimName = "stash-a-content-pvc";
                }
              ];
            };
          };
        };
      };
      stash-a-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "stash-a-config-pvc";
          labels = {
            "app.kubernetes.io/name" = "stash-a";
            "recurring-job.longhorn.io/source" = "enabled";
            "recurring-job.longhorn.io/backup-daily" = "enabled";
          };
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "2Gi";
        };
      };
      stash-a-store-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "stash-a-store-pvc";
          labels = {
            "app.kubernetes.io/name" = "stash-a";
            "recurring-job.longhorn.io/source" = "enabled";
            "recurring-job.longhorn.io/backup-daily" = "enabled";
          };
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "10Gi";
        };
      };
      stash-a-content-nfs-pv.content = {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "stash-a-content-nfs-pv";
          labels."app.kubernetes.io/name" = "stash-a";
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
            path = "/nas_data_primary/ad";
            readOnly = true;
          };
        };
      };
      stash-a-content-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "stash-a-content-pvc";
          labels."app.kubernetes.io/name" = "stash-a";
        };
        spec = {
          selector.matchLabels."app.kubernetes.io/name" = "stash-a";
          accessModes = [ "ReadOnlyMany" ];
          volumeName = "stash-a-content-nfs-pv";
          storageClassName = "";
          resources.requests.storage = "1Ti";
        };
      };
      stash-a-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "stash-a";
          labels."app.kubernetes.io/name" = "stash-a";
        };
        spec = {
          selector."app.kubernetes.io/name" = "stash-a";
          ports = [
            {
              port = 9999;
              targetPort = 9999;
            }
          ];
        };
      };
      stash-a-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "stash-a";
          labels."app.kubernetes.io/name" = "stash-a";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Ad content serving";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Media";
            "gethomepage.dev/icon" = "stash.png";
            "gethomepage.dev/name" = "stash-a";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "stash-a.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "stash-a";
                        port.number = 9999;
                      };
                    };
                  }
                ];
              };
            }
          ];
        };
      };

      # B
      stash-b-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "stash-b";
          labels."app.kubernetes.io/name" = "stash-b";
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

          selector.matchLabels."app.kubernetes.io/name" = "stash-b";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "stash-b";
              annotations."diun.enable" = "true";
            };
            spec = {
              securityContext.supplementalGroups = [ config.users.groups.nas-ad-view.gid ];
              containers = [
                {
                  name = "stash-b";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  env = stashShareEnvironment;
                  ports = [ { containerPort = 9999; } ];
                  volumeMounts = [
                    {
                      mountPath = "/store";
                      name = "store";
                    }
                    {
                      mountPath = "/root/.stash";
                      name = "config";
                    }
                    {
                      mountPath = "/data";
                      name = "content";
                    }
                    {
                      mountPath = "/cache";
                      name = "cache";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "cache";
                  emptyDir = { };
                }
                {
                  name = "config";
                  persistentVolumeClaim.claimName = "stash-b-config-pvc";
                }
                {
                  name = "store";
                  persistentVolumeClaim.claimName = "stash-b-store-pvc";
                }
                {
                  name = "content";
                  persistentVolumeClaim.claimName = "stash-b-content-pvc";
                }
              ];
            };
          };
        };
      };
      stash-b-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "stash-b-config-pvc";
          labels = {
            "app.kubernetes.io/name" = "stash-b";
            "recurring-job.longhorn.io/source" = "enabled";
            "recurring-job.longhorn.io/backup-daily" = "enabled";
          };
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "1Gi";
        };
      };
      stash-b-store-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "stash-b-store-pvc";
          labels = {
            "app.kubernetes.io/name" = "stash-b";
            "recurring-job.longhorn.io/source" = "enabled";
            "recurring-job.longhorn.io/backup-daily" = "enabled";
          };
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "2Gi";
        };
      };
      stash-b-content-nfs-pv.content = {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "stash-b-content-nfs-pv";
          labels."app.kubernetes.io/name" = "stash-b";
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
            path = "/nas_data_primary/ad";
            readOnly = true;
          };
        };
      };
      stash-b-content-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "stash-b-content-pvc";
          labels."app.kubernetes.io/name" = "stash-b";
        };
        spec = {
          selector.matchLabels."app.kubernetes.io/name" = "stash-b";
          accessModes = [ "ReadOnlyMany" ];
          volumeName = "stash-b-content-nfs-pv";
          storageClassName = "";
          resources.requests.storage = "1Ti";
        };
      };
      stash-b-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "stash-b";
          labels."app.kubernetes.io/name" = "stash-b";
        };
        spec = {
          selector."app.kubernetes.io/name" = "stash-b";
          ports = [
            {
              port = 9999;
              targetPort = 9999;
            }
          ];
        };
      };
      stash-b-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "stash-b";
          labels."app.kubernetes.io/name" = "stash-b";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Ad content serving";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Media";
            "gethomepage.dev/icon" = "stash.png";
            "gethomepage.dev/name" = "stash-b";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "stash-b.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "stash-b";
                        port.number = 9999;
                      };
                    };
                  }
                ];
              };
            }
          ];
        };
      };
    };
  };
}
