{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/marcopiovanello/yt-dlp-web-ui";
    imageDigest = "sha256:17e6c9aeedea6799d768d4352c9b0a057b99e855a59edc37fb261d264afc626d";
    hash = "sha256-/2UgKh3uP745dAYjz4VmrbuBYw4o3ZqrQ6V5srILUHw=";
    finalImageTag = "latest";
    arch = "amd64";
  };
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    images = [ image ];
    manifests = {
      yt-dlp-web-ui-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "yt-dlp-web-ui";
          labels."app.kubernetes.io/name" = "yt-dlp-web-ui";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "yt-dlp-web-ui";
          template = {
            metadata.labels."app.kubernetes.io/name" = "yt-dlp-web-ui";
            spec = {
              containers = [
                {
                  name = "yt-dlp-web-ui";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  env = [ ];
                  ports = [ { containerPort = 3033; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      yt-dlp-web-ui-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "yt-dlp-web-ui";
          labels."app.kubernetes.io/name" = "yt-dlp-web-ui";
        };
        spec = {
          selector."app.kubernetes.io/name" = "yt-dlp-web-ui";
          ports = [
            {
              port = 3033;
              targetPort = 3033;
            }
          ];
        };
      };
      yt-dlp-web-ui-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "yt-dlp-web-ui";
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
                    path = "/yt-dlp-web-ui";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "yt-dlp-web-ui";
                        port.number = 3033;
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
