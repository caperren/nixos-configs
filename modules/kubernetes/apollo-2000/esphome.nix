{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "esphome/esphome";
    imageDigest = "sha256:c625ac6e9f119cd501293ce47a04aea3042a9428108209f368262d8867aa2920";
    hash = "sha256-wKXDnBdfTuKV+Wn79/VliiDR76rmrASTHlPCoxWC6gs=";
    finalImageTag = "2025.12.5";
    arch = "amd64";
  };
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    images = [ image ];
    manifests = {
      esphome-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "esphome";
          labels."app.kubernetes.io/name" = "esphome";
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

          selector.matchLabels."app.kubernetes.io/name" = "esphome";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "esphome";
              annotations."diun.enable" = "true";
            };
            spec = {
              containers = [
                {
                  name = "esphome";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 6052; } ];
                  volumeMounts = [
                    {
                      mountPath = "/config";
                      name = "config";
                    }
                  ];
                }
              ];
              hostNetwork = true;
              volumes = [
                {
                  name = "config";
                  persistentVolumeClaim.claimName = "esphome-config-pvc";
                }
              ];
            };
          };
        };
      };
      esphome-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "esphome-config-pvc";
          labels."app.kubernetes.io/name" = "esphome";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "10Gi";
        };
      };
      esphome-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "esphome-service";
          labels."app.kubernetes.io/name" = "esphome";
        };
        spec = {
          selector."app.kubernetes.io/name" = "esphome";
          ports = [
            {
              port = 6052;
              targetPort = 6052;
            }
          ];
        };
      };
      esphome-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "esphome";
          labels."app.kubernetes.io/name" = "esphome";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Espressif esp-based smart home management";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Smart Home";
            "gethomepage.dev/icon" = "esphome.png";
            "gethomepage.dev/name" = "ESPHome";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "esphome.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "esphome-service";
                        port.number = 6052;
                      };
                    };
                  }
                ];
              };
            }
            {
              host = "esphome.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "esphome-service";
                        port.number = 6052;
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
