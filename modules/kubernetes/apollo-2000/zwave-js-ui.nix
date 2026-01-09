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
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
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
          selector.matchLabels."app.kubernetes.io/name" = "zwave-js-ui";
          template = {
            metadata.labels."app.kubernetes.io/name" = "zwave-js-ui";
            spec = {
              containers = [
                {
                  name = "zwave-js-ui";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 8091; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
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
              port = 8091;
              targetPort = 8091;
            }
          ];
        };
      };
      zwave-js-ui-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "zwave-js-ui";
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
                    path = "/zwave-js-ui";
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
            })
          ];
        };
      };
    };
  };
}
