{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/open-webui/open-webui";
    imageDigest = "sha256:1fb4ea74da47d34a6b43122fe25e09104f2277d921d76ee153cb31092528923d";
    hash = "sha256-4ueqSwuxD5c7pNtAdqj7cyuGpF7PdiMFQVOgmWyxG8g=";
    finalImageTag = "0.7.2-ollama";
    arch = "amd64";
  };
  ollamaServiceCfg = config.services.k3s.manifests.ollama-service.content;
  ollamaServiceName = ollamaServiceCfg.metadata.name;
  ollamaServicePort = toString (builtins.elemAt ollamaServiceCfg.spec.ports 0).port;
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
    images = [ image ];
    manifests = {
      openwebui-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "openwebui";
          labels."app.kubernetes.io/name" = "openwebui";
        };
        spec = {
          replicas = 0;
          #          strategy = {
          #            type = "RollingUpdate";
          #            rollingUpdate = {
          #              maxSurge = 0;
          #              maxUnavailable = 1;
          #            };
          #          };

          selector.matchLabels."app.kubernetes.io/name" = "openwebui";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "openwebui";
              annotations."diun.enable" = "true";
            };
            spec = {
              containers = [
                {
                  name = "openwebui";
                  image = "${image.imageName}:${image.imageTag}";
                  #                  envFrom = [ { secretRef.name = "openwebui-environment-secret"; } ];
                  env = [
                    {
                      name = "OLLAMA_BASE_URL";
                      value = "http://${ollamaServiceName}.default.svc.cluster.local:${ollamaServicePort}";
                    }
                  ];
                  ports = [ { containerPort = 8080; } ];
                  volumeMounts = [
                    {
                      mountPath = "/app/backend/data";
                      name = "data";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "openwebui-data-pvc";
                }
              ];
            };
          };
        };
      };
      openwebui-data-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "openwebui-data-pvc";
          labels."app.kubernetes.io/name" = "openwebui";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "10Gi";
        };
      };
      openwebui-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "openwebui";
          labels."app.kubernetes.io/name" = "openwebui";
        };
        spec = {
          selector."app.kubernetes.io/name" = "openwebui";
          ports = [
            {
              port = 8080;
              targetPort = 8080;
            }
          ];
        };
      };
      openwebui-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "openwebui";
          labels."app.kubernetes.io/name" = "openwebui";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Frontend for local AI models";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "AI";
            "gethomepage.dev/icon" = "openwebui.png";
            "gethomepage.dev/name" = "Open WebUI";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "openwebui.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "openwebui";
                        port.number = 8080;
                      };
                    };
                  }
                ];
              };
            }
            {
              host = "openwebui.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "openwebui";
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
