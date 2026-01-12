{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "homeassistant/home-assistant";
    imageDigest = "sha256:97d63b3d0028b6b52ad8e5ac7b014c3404e69bf1656b5489eec48b59184e0bc7";
    hash = "sha256-Fv4LREiKpEgk4EA8yZ+byKQxUyjmLkMpsDUonD1cZxc=";
    finalImageTag = "2026.1.0";
    arch = "amd64";
  };
  zigbeeUsbDevice = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_70e285591fe8ec1181258160e89bdf6f-if00-port0";
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    images = [ image ];
    manifests = {
      home-assistant-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "home-assistant";
          labels."app.kubernetes.io/name" = "home-assistant";
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

          selector.matchLabels."app.kubernetes.io/name" = "home-assistant";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "home-assistant";
              annotations."diun.enable" = "true";
            };
            spec = {
              containers = [
                {
                  name = "busybox";
                  image = "busybox";
                  command = [
                    "sleep"
                    "3600"
                  ];
                   volumeMounts = [
                    {
                      mountPath = "/config";
                      name = "config";
                    }
                  ];
                }
#                {
#                  name = "home-assistant";
#                  image = "${image.imageName}:${image.imageTag}";
#                  env = [
#                    {
#                      name = "TZ";
#                      value = "America/Los_Angeles";
#                    }
#                  ];
#                  ports = [ { containerPort = 8123; } ];
#                  volumeMounts = [
#                    {
#                      name = "localtime";
#                      mountPath = "/etc/localtime";
#                      readOnly = true;
#                    }
#                    {
#                      mountPath = "/config";
#                      name = "config";
#                    }
#                  ];
#                }
              ];
              hostNetwork = true;
              volumes = [
                {
                  name = "localtime";
                  hostPath = {
                    path = "/etc/localtime";
                  };
                }
                {
                  name = "config";
                  persistentVolumeClaim.claimName = "home-assistant-config-pvc";
                }
              ];
            };
          };
        };
      };
      home-assistant-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "home-assistant-config-pvc";
          labels."app.kubernetes.io/name" = "home-assistant";
        };
        spec = {
          accessModes = [ "ReadWriteMany" ];
          storageClassName = "longhorn";
          resources.requests.storage = "2Gi";
        };
      };
      home-assistant-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "home-assistant";
          labels."app.kubernetes.io/name" = "home-assistant";
        };
        spec = {
          selector."app.kubernetes.io/name" = "home-assistant";
          ports = [
            {
              port = 8123;
              targetPort = 8123;
            }
          ];
        };
      };
      home-assistant-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "home-assistant";
          labels."app.kubernetes.io/name" = "home-assistant";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Open source home automation";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Smart Home";
            "gethomepage.dev/icon" = "home-assistant.png";
            "gethomepage.dev/name" = "Home Assistant";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "home-assistant.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "home-assistant";
                        port.number = 8123;
                      };
                    };
                  }
                ];
              };
            }
            {
              host = "home-assistant.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "home-assistant";
                        port.number = 8123;
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
