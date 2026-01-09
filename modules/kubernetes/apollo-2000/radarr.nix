{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/hotio/radarr";
    imageDigest = "sha256:37f4b13365c442fc486741963ddabb110c7e0dfc81fa9a1ea1e907ca9485d35e";
    hash = "sha256-wxowepEmE4pQzjZKurFyOs33vpF3ayjvoZ8vl9ZGdVM=";
    finalImageTag = "release-6.0.4.10291";
    arch = "amd64";
  };
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02"){
    images = [ image ];
    manifests = {
      radarr-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "radarr";
          labels."app.kubernetes.io/name" = "radarr";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "radarr";
          template = {
            metadata.labels."app.kubernetes.io/name" = "radarr";
            spec = {
              containers = [
                {
                  name = "radarr";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 7878; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      radarr-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "radarr";
          labels."app.kubernetes.io/name" = "radarr";
        };
        spec = {
          selector."app.kubernetes.io/name" = "radarr";
          ports = [
            {
              port = 7878;
              targetPort = 7878;
            }
          ];
        };
      };
      radarr-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "radarr";
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
                    path = "/radarr";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "radarr";
                        port.number = 7878;
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
