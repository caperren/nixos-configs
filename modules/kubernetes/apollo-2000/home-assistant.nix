{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "homeassistant/home-assistant";
    imageDigest = "sha256:9a5a3eb4a213dfb25932dee9dc6815c9305f78cecb5afa716fa2483163d8fb5b";
    hash = "sha256-bprEmYJY3wRxtb+/8JLZ8M7lvjo6vDJsBZIXAwjtN78=";
    finalImageTag = "2025.12.5";
    arch = "amd64";
  };
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
          selector.matchLabels."app.kubernetes.io/name" = "home-assistant";
          template = {
            metadata.labels."app.kubernetes.io/name" = "home-assistant";
            spec = {
              containers = [
                {
                  name = "home-assistant";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 8123; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
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
          annotations = {
            "kubernetes.io/ingress.class" = "traefik";
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            ({
              http = {
                paths = [
                  {
                    path = "/home-assistant";
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
            })
          ];
        };
      };
    };
  };
}
