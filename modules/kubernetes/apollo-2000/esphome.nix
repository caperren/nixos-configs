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
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
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
              securityContext.supplementalGroups = [
                config.users.groups.pod-configs-esphome.gid
              ];
              containers = [
                {
                  name = "esphome";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
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
      diun-config-nfs-pv.content = {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "esphome-config-nfs-pv";
          labels."app.kubernetes.io/name" = "esphome";
        };
        spec = {
          capacity.storage = "1Ti";
          accessModes = [ "ReadWriteMany" ];
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
            path = "/nas_data_primary/pod_configs/esphome";
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
          selector.matchLabels."app.kubernetes.io/name" = "esphome";
          accessModes = [ "ReadWriteMany" ];
          volumeName = "esphome-config-nfs-pv";
          storageClassName = "";
          resources.requests.storage = "1Ti";
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
