{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageConfig = {
    imageName = "docker.io/zwavejs/zwave-js-ui";
    imageDigest = "sha256:944d39fe22d8985ddcbef0849cd22984b8340448f742195821cc34f7a9ca1bb4";
    hash = "sha256-UdpeBybR14AP8Tx8QM4PGJMIljkWQwM9q0DZIIYW0qc=";
    finalImageName = "docker.io/zwavejs/zwave-js-ui";
    finalImageTag = "11.19.1";
  };
  image = pkgs.dockerTools.pullImage imageConfig // {
    arch = "amd64";
  };
  zWaveUsbDevice = "/dev/serial/by-id/usb-Nabu_Casa_ZWA-2_80B54EE7E6E0-if00";
  allowedReplicas = if config."perren.cloud".maintenance.kube then 0 else 1;
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
          replicas = allowedReplicas;
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
              securityContext = {
                runAsUser = 0;
                runAsGroup = 0;
                supplementalGroups = [ config.users.groups.pod-configs-zwave-js-ui.gid ];
              };
              containers = [
                {
                  name = "zwave-js-ui";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  resources.limits."squat.ai/zwave" = "1";
                  envFrom = [ { secretRef.name = "zwave-js-ui-environment-secret"; } ];
                  env = [
                    {
                      name = "TZ";
                      value = "America/Los_Angeles";
                    }
                  ];
                  ports = [
                    {
                      name = "http";
                      containerPort = 8091;
                      protocol = "TCP";
                    }
                    {
                      name = "js-websocket";
                      containerPort = 3000;
                      protocol = "TCP";
                    }
                  ];
                  volumeMounts = [
                    {
                      mountPath = "/dev/zwave";
                      name = "adapter";
                    }
                    {
                      mountPath = "/usr/src/app/store";
                      name = "config";
                    }
                  ];
                  livenessProbe = {
                    exec = {
                      command = [
                        "sh"
                        "-c"
                        "ls /dev/zwave >/dev/null 2>&1"
                      ];
                    };
                    initialDelaySeconds = 30;
                    periodSeconds = 10;
                    timeoutSeconds = 2;
                    failureThreshold = 3;
                  };
                }
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
      zwave-js-ui-config-nfs-pv.content = {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "zwave-js-ui-config-nfs-pv";
          labels."app.kubernetes.io/name" = "zwave-js-ui";
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
            path = "/nas_data_primary/pod_configs/zwave-js-ui";
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
          selector.matchLabels."app.kubernetes.io/name" = "zwave-js-ui";
          accessModes = [ "ReadWriteMany" ];
          volumeName = "zwave-js-ui-config-nfs-pv";
          storageClassName = "";
          resources.requests.storage = "1Ti";
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
