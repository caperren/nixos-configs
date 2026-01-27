{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageConfig = {
    imageName = "gotson/komga";
    imageDigest = "sha256:09129eae6eff50337f039bd6e99d995126cb03226950c80e9864cbc05f10a661";
    hash = "sha256-GoAaZtsgB8sPtOKS4cV9wL9UYqhc3rNMbBpVFu6uctE=";
    finalImageTag = "1.23.6";
  };
  image = pkgs.dockerTools.pullImage imageConfig // {
    arch = "amd64";
  };

  allowedReplicas = if config."perren.cloud".maintenance.nfs then 0 else 1;
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    images = [ image ];
    manifests = {
      komga-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "komga";
          labels."app.kubernetes.io/name" = "komga";
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

          selector.matchLabels."app.kubernetes.io/name" = "komga";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "komga";
              annotations."diun.enable" = "true";
            };
            spec = {
              securityContext.supplementalGroups = [ config.users.groups.nas-komga-view.gid ];
              containers = [
                {
                  name = "komga";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  env = [ ];
                  ports = [ { containerPort = 25600; } ];
                  volumeMounts = [
                    {
                      mountPath = "/config";
                      name = "config";
                    }
                    {
                      mountPath = "/data";
                      name = "data";
                      readOnly = true;
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "config";
                  persistentVolumeClaim.claimName = "komga-config-pvc";
                }
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "komga-data-pvc";
                }
              ];
            };
          };
        };
      };
      komga-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "komga-config-pvc";
          labels."app.kubernetes.io/name" = "komga";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "2Gi";
        };
      };
      komga-data-nfs-pv.content = {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "komga-data-nfs-pv";
          labels."app.kubernetes.io/name" = "komga";
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
            path = "/nas_data_primary/komga";
            readOnly = true;
          };
        };
      };
      komga-data-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "komga-data-pvc";
          labels."app.kubernetes.io/name" = "komga";
        };
        spec = {
          selector.matchLabels."app.kubernetes.io/name" = "komga";
          accessModes = [ "ReadOnlyMany" ];
          volumeName = "komga-data-nfs-pv";
          storageClassName = "";
          resources.requests.storage = "1Ti";
        };
      };
      komga-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "komga";
          labels."app.kubernetes.io/name" = "komga";
        };
        spec = {
          selector."app.kubernetes.io/name" = "komga";
          ports = [
            {
              port = 25600;
              targetPort = 25600;
            }
          ];
        };
      };
      komga-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "komga";
          labels."app.kubernetes.io/name" = "komga";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Media server for comics and books";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Media";
            "gethomepage.dev/icon" = "komga.png";
            "gethomepage.dev/name" = "Komga";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "komga.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "komga";
                        port.number = 25600;
                      };
                    };
                  }
                ];
              };
            }
            {
              host = "komga.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "komga";
                        port.number = 25600;
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
