{
  config,
  pkgs,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "esphome/esphome";
    imageDigest = "sha256:c42c7485cf18d9a9e021b2d073bca0fd58d9457a51068a5720da67be92d2dfad";
    hash = "sha256-QIZXdnnMGGQxJWPwvb339mibT5HQ/H2qhBQrRhAkH/c=";
    finalImageTag = "2025.12.4";
    arch = "amd64";
  };
in
{
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
          selector.matchLabels."app.kubernetes.io/name" = "esphome";
          template = {
            metadata.labels."app.kubernetes.io/name" = "esphome";
            spec = {
              containers = [
                {
                  name = "esphome";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 6052; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      esphome-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "esphome";
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
                    path = "/esphome";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "esphome";
                        port.number = 6052;
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
