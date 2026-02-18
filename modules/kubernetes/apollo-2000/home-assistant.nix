{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageConfig = {
    imageName = "docker.io/homeassistant/home-assistant";
    imageDigest = "sha256:17441c45ba14560b4ef727ee06aac4d605cf0dc0625fc4f2e043cb2551d72749";
    hash = "sha256-O0AfG7dy/ihDPu7lzk3aMpt4t2ncosC7cH7tVlZeBTk=";
    finalImageName = "docker.io/homeassistant/home-assistant";
    finalImageTag = "2026.2.1";
  };
  image = pkgs.dockerTools.pullImage imageConfig // {
    arch = "amd64";
  };

  zigbeeUsbDevice = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_70e285591fe8ec1181258160e89bdf6f-if00-port0";
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
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
                "diun.max_tags" = "5";
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
          labels = {
            "app.kubernetes.io/name" = "home-assistant";
            "recurring-job.longhorn.io/source" = "enabled";
            "recurring-job.longhorn.io/backup-daily" = "enabled";
          };
        };
        spec = {
          accessModes = [ "ReadWriteMany" ];
          storageClassName = "longhorn";
          resources.requests.storage = "20Gi";
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
