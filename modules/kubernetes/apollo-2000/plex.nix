{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "plexinc/pms-docker";
    imageDigest = "sha256:9c03c26b9479ba9a09935f3367459bfdc8d21545f42ed2a13258983c5be1b252";
    hash = "sha256-Slv7v5Bf9/NBsYfEIbUBQGeHYrrSvRlVmibQT4ftA1o=";
    finalImageTag = "1.42.2.10156-f737b826c";
    arch = "amd64";
  };
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02"){
    images = [ image ];
    manifests = {
      plex-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "plex";
          labels."app.kubernetes.io/name" = "plex";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "plex";
          template = {
            metadata.labels."app.kubernetes.io/name" = "plex";
            spec = {
              containers = [
                {
                  name = "plex";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 32400; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      plex-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "plex";
          labels."app.kubernetes.io/name" = "plex";
        };
        spec = {
          selector."app.kubernetes.io/name" = "plex";
          ports = [
            {
              port = 32400;
              targetPort = 32400;
            }
          ];
        };
      };
      plex-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "plex";
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
                    path = "/plex";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "plex";
                        port.number = 32400;
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
