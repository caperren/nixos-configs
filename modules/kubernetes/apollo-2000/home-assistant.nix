{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageConfig = {
    imageName = "homeassistant/home-assistant";
    imageDigest = "sha256:c36741490472518338323db8ee67775d7df70d2fa1f68eff9b9e63679fe64a18";
    hash = "sha256-ZuPa4FQb0/EcQOLn26E5bDsLwvCHxe1iQLJ4rZiVHKo=";
    finalImageName = "homeassistant/home-assistant";
    finalImageTag = "2026.1.3";
  };
  image = pkgs.dockerTools.pullImage imageConfig // { arch = "amd64"; };

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
              annotations = {
                "diun.enable" = "true";
                "diun.watch_repo" = "true";
                "diun.sort_tags" = "semver";
                "diun.max_tags" = 5;
                "diun.include_tags" = "${imageConfig.finalImageTag};^[0-9]{4}.[0-9].[0-9]$";
              };
            };
            spec = {
              terminationGracePeriodSeconds = 30;
              containers = [
                {
                  name = "home-assistant";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  resources.limits."squat.ai/zigbee" = "1";
                  env = [
                    {
                      name = "TZ";
                      value = "America/Los_Angeles";
                    }
                  ];
                  ports = [ { containerPort = 8123; } ];
                  volumeMounts = [
                    {
                      name = "localtime";
                      mountPath = "/etc/localtime";
                      readOnly = true;
                    }
                    {
                      mountPath = "/dev/ttyUSB0";
                      name = "adapter";
                    }
                    {
                      mountPath = "/config";
                      name = "config";
                    }
                  ];
                  livenessProbe = {
                    exec = {
                      command = [
                        "sh"
                        "-c"
                        "ls /dev/ttyUSB0 >/dev/null 2>&1"
                      ];
                    };
                    initialDelaySeconds = 30;
                    periodSeconds = 10;
                    timeoutSeconds = 2;
                    failureThreshold = 3;
                  };
                }
              ];
              hostNetwork = true;
              dnsPolicy = "ClusterFirstWithHostNet";
              volumes = [
                {
                  name = "adapter";
                  hostPath = {
                    path = zigbeeUsbDevice;
                  };
                }
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
          resources.requests.storage = "5Gi";
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
