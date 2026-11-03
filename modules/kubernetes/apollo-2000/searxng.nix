{
  config,
  pkgs,
  lib,
  ...
}:
let
  searxngImageConfig = {
    imageName = "docker.io/searxng/searxng";
    imageDigest = "sha256:6ba4dc74513d1e3da2bde4a6c419a8c4a0ec3475ada97d9637d8f5a75ec8b595";
    hash = "sha256-68PfxrmX+0GQQXkAMTfp3WQFD/obbSvcIbPsfU1Z7xM=";
    finalImageName = "docker.io/searxng/searxng";
    finalImageTag = "2026.5.21-b9340f50c";
  };
  valkeyImageConfig = {
    imageName = "docker.io/valkey/valkey";
    imageDigest = "sha256:a35428eba9043cc0b79dbe54100f0c92784f2de00ad09b01182bfb1c5c83d1bd";
    hash = "sha256-lAnFdjVLtQsXEsCsYr7FKaoeViW2zjBVXrjINvvXAu4=";
    finalImageName = "docker.io/valkey/valkey";
    finalImageTag = "9-alpine";
  };
  searxngImage = pkgs.dockerTools.pullImage searxngImageConfig // {
    arch = "amd64";
  };
  valkeyImage = pkgs.dockerTools.pullImage searxngImageConfig // {
    arch = "amd64";
  };

  allowedReplicas = 1;
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
    images = [ searxngImage valkeyImage ];
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
              securityContext.supplementalGroups = [ config.users.groups.pod-configs-zwave-js-ui.gid ];
              containers = [
                {
                  name = "home-assistant";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
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
      home-assistant-config-nfs-pv.content = {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "home-assistant-config-nfs-pv";
          labels."app.kubernetes.io/name" = "home-assistant";
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
            path = "/nas_data_primary/pod_configs/home-assistant";
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
          selector.matchLabels."app.kubernetes.io/name" = "home-assistant";
          accessModes = [ "ReadWriteMany" ];
          volumeName = "home-assistant-config-nfs-pv";
          storageClassName = "";
          resources.requests.storage = "1Ti";
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
