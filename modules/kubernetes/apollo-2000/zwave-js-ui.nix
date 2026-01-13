{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "zwavejs/zwave-js-ui";
    imageDigest = "sha256:a7036e59a9d7916d1f92f2fa1e0b9f4a5ed317fc8bef38756368f7c865e0e95a";
    hash = "sha256-q8FOH4O6lMwN/0K6r+5E2q/TbitL3Oos1UqKM/PfQAs=";
    finalImageTag = "11.9.1";
    arch = "amd64";
  };
  zWaveUsbDevice = "/dev/serial/by-id/usb-Nabu_Casa_ZWA-2_80B54EE7E6E0-if00";
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  sops = {
    secrets."zwave-js-ui/environment/SESSION_SECRET".sopsFile = ../../../secrets/apollo-2000.yaml;

    templates.zwave-js-ui-environment-secret = {
      content = builtins.toJSON {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "zwave-js-ui-environment-secret";
          labels."app.kubernetes.io/name" = "zwave-js-ui";
        };
        stringData.SESSION_SECRET = config.sops.placeholder."zwave-js-ui/environment/SESSION_SECRET";
      };
      path = "/var/lib/rancher/k3s/server/manifests/zwave-js-ui-environment-secret.yaml";
    };
  };

  services.k3s = {
    images = [ image ];
    manifests = {
      zwave-js-ui-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "zwave-js-ui";
          labels."app.kubernetes.io/name" = "zwave-js-ui";
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

          selector.matchLabels."app.kubernetes.io/name" = "zwave-js-ui";

          template = {
            metadata.labels."app.kubernetes.io/name" = "zwave-js-ui";
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
                      mountPath = "/usr/src/app/store";
                      name = "config";
                    }
                  ];
                }
                #                {
                #                  name = "zwave-js-ui";
                #                  image = "${image.imageName}:${image.imageTag}";
                #                  resources.limits."squat.ai/zwave" = "1";
                #                  envFrom = [ { secretRef.name = "zwave-js-ui-environment-secret"; } ];
                #                  env = [
                #                    {
                #                      name = "TZ";
                #                      value = "America/Los_Angeles";
                #                    }
                #                  ];
                #                  ports = [
                #                    {
                #                      name = "http";
                #                      containerPort = 8091;
                #                      protocol = "TCP";
                #                    }
                #                    {
                #                      name = "js-websocket";
                #                      containerPort = 3000;
                #                      protocol = "TCP";
                #                    }
                #                  ];
                #                  volumeMounts = [
                #                    {
                #                      mountPath = zWaveUsbDevice;
                #                      name = "adapter";
                #                    }
                #                    {
                #                      mountPath = "/usr/src/app/store";
                #                      name = "config";
                #                    }
                #                  ];
                #                }
              ];
              volumes = [
                {
                  name = "adapter";
                  hostPath = {
                    path = zWaveUsbDevice;
                  };
                }
                {
                  name = "config";
                  persistentVolumeClaim.claimName = "zwave-js-ui-config-pvc";
                }
              ];
            };
          };
        };
      };
      zwave-js-ui-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "zwave-js-ui-config-pvc";
          labels."app.kubernetes.io/name" = "zwave-js-ui";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "1Gi";
        };
      };
      zwave-js-ui-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "zwave-js-ui";
          labels."app.kubernetes.io/name" = "zwave-js-ui";
        };
        spec = {
          selector."app.kubernetes.io/name" = "zwave-js-ui";
          ports = [
            {
              name = "http";
              port = 8091;
              targetPort = 8091;
            }
            {
              name = "js-websocket";
              port = 3000;
              targetPort = 3000;
            }
          ];
        };
      };
      zwave-js-ui-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "zwave-js-ui";
          labels."app.kubernetes.io/name" = "zwave-js-ui";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Z-Wave control panel";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Smart Home";
            "gethomepage.dev/icon" = "zwave-js-ui.png";
            "gethomepage.dev/name" = "Z-Wave JS UI";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "zwave-js-ui.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "zwave-js-ui";
                        port.number = 8091;
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
