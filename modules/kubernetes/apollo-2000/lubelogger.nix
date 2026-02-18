{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageConfig = {
    imageName = "ghcr.io/hargata/lubelogger";
    imageDigest = "sha256:c4277e12e005af6a3a95f3c32ce2aac6fbb035cb74e58d5f8d3cac4c27307eaf";
    hash = "sha256-4yQz9WCa52CIJpD8h4u1hZZ9NTEI4we1UsJ51JvBnzU=";
    finalImageName = "ghcr.io/hargata/lubelogger";
    finalImageTag = "v1.6.0";
  };
  image = pkgs.dockerTools.pullImage imageConfig // {
    arch = "amd64";
  };
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
    images = [ image ];
    manifests = {
      lubelogger-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "lubelogger";
          labels."app.kubernetes.io/name" = "lubelogger";
        };
        spec = {
          replicas = 1;
          strategy = {
            type = "RollingUpdate";
            rollingUpdate = {
              maxSurge = 0;
              maxUnavailable = 1;
            };
          };

          selector.matchLabels."app.kubernetes.io/name" = "lubelogger";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "lubelogger";
              annotations = {
                "diun.enable" = "true";
                "diun.watch_repo" = "true";
                "diun.sort_tags" = "semver";
                "diun.max_tags" = "5";
                "diun.include_tags" = "${imageConfig.finalImageTag};^v[0-9].[0-9].[0-9]$";
              };
            };
            spec = {
              containers = [
                {
                  name = "lubelogger";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "TZ";
                      value = "America/Los_Angeles";
                    }
                    {
                      name = "LC_ALL";
                      value = "en_US";
                    }
                    {
                      name = "LANG";
                      value = "en_US";
                    }
                  ];
                  ports = [ { containerPort = 8080; } ];
                  volumeMounts = [
                    {
                      name = "localtime";
                      mountPath = "/etc/localtime";
                      readOnly = true;
                    }
                    {
                      mountPath = "/App/data";
                      name = "data";
                    }
                    {
                      mountPath = "/root/.aspnet/DataProtection-Keys";
                      name = "keys";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "localtime";
                  hostPath.path = "/etc/localtime";
                }
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "lubelogger-data-pvc";
                }
                {
                  name = "keys";
                  persistentVolumeClaim.claimName = "lubelogger-keys-pvc";
                }
              ];
            };
          };
        };
      };
      lubelogger-data-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "lubelogger-data-pvc";
          labels = {
            "app.kubernetes.io/name" = "lubelogger";
            "recurring-job.longhorn.io/source" = "enabled";
            "recurring-job.longhorn.io/backup-daily" = "enabled";
          };
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "64Mi";
        };
      };
      lubelogger-keys-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "lubelogger-keys-pvc";
          labels = {
            "app.kubernetes.io/name" = "lubelogger";
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
      lubelogger-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "lubelogger";
          labels."app.kubernetes.io/name" = "lubelogger";
        };
        spec = {
          selector."app.kubernetes.io/name" = "lubelogger";
          ports = [
            {
              port = 8080;
              targetPort = 8080;
            }
          ];
        };
      };
      lubelogger-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "lubelogger";
          labels."app.kubernetes.io/name" = "lubelogger";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Open source vehicle maintenance tracking";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Documentation";
            "gethomepage.dev/icon" = "lubelogger.png";
            "gethomepage.dev/name" = "Lube Logger";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "lubelogger.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "lubelogger";
                        port.number = 8080;
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
