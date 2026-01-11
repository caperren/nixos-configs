{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/jellyfin/jellyfin";
    imageDigest = "sha256:cd7e4cb71812dd76988a725da615e37c6d0d24c200be904ad5d183e51f1dc6ed";
    hash = "sha256-8FujxEYyhcFfyP5cwemHSeR+l/zYpk49pQymuMlH6So=";
    finalImageTag = "10.11.5";
    arch = "amd64";
  };
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
    images = [ image ];
    manifests = {
      jellyfin-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "jellyfin";
          labels."app.kubernetes.io/name" = "jellyfin";
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

          selector.matchLabels."app.kubernetes.io/name" = "jellyfin";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "jellyfin";
              annotations."diun.enable" = "true";
            };
            spec = {
              containers = [
                {
                  name = "jellyfin";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [
                  ];
                  ports = [ { containerPort = 8096; } ];
                  volumeMounts = [
                    {
                      mountPath = "/cache";
                      name = "cache";
                    }
                    {
                      mountPath = "/config";
                      name = "config";
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
                  persistentVolumeClaim.claimName = "jellyfin-config-pvc";
                }
              ];
            };
          };
        };
      };
      jellyfin-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "jellyfin-config-pvc";
          labels."app.kubernetes.io/name" = "jellyfin";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "1Gi";
        };
      };
      jellyfin-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "jellyfin";
          labels."app.kubernetes.io/name" = "jellyfin";
        };
        spec = {
          selector."app.kubernetes.io/name" = "jellyfin";
          ports = [
            {
              port = 8096;
              targetPort = 8096;
            }
          ];
        };
      };
      jellyfin-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "jellyfin";
          labels."app.kubernetes.io/name" = "jellyfin";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Free software media system";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Media";
            "gethomepage.dev/icon" = "jellyfin.png";
            "gethomepage.dev/name" = "Jellyfin";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "jellyfin.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "jellyfin";
                        port.number = 8096;
                      };
                    };
                  }
                ];
              };
            }
            {
              host = "jellyfin.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "jellyfin";
                        port.number = 8096;
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
