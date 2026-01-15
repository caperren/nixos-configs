{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "stashapp/stash";
    imageDigest = "sha256:4cac18873ea052f03510602d9e1a9b29e6241a393a111479010292b7a1e28a5e";
    hash = "sha256-D3XMtByDotpCR/Q4CqoKzL1n/wGHgXMyPNYpkUxxlXs=";
    finalImageTag = "v0.30.1";
    arch = "amd64";
  };
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    images = [ image ];
    manifests = {
      stash-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "stash";
          labels."app.kubernetes.io/name" = "stash";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "stash";
          template = {
            metadata.labels."app.kubernetes.io/name" = "stash";
            spec = {
              containers = [
                {
                  name = "stash";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  env = [ ];
                  ports = [ { containerPort = 9999; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      stash-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "stash";
          labels."app.kubernetes.io/name" = "stash";
        };
        spec = {
          selector."app.kubernetes.io/name" = "stash";
          ports = [
            {
              port = 9999;
              targetPort = 9999;
            }
          ];
        };
      };
      stash-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "stash";
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
                    path = "/stash";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "stash";
                        port.number = 9999;
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
