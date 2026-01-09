{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "crazymax/spliit";
    imageDigest = "sha256:b0cb61acc5e75e5aa81dd63d0b49311ff26332b42c1b09c2b25a807503ad5572";
    hash = "sha256-ac6BuKp8SUXJdT519Px8O048sNj3F0wox+y15N7rAI8=";
    finalImageTag = "1.18.0";
    arch = "amd64";
  };
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02"){
    images = [ image ];
    manifests = {
      spliit-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "spliit";
          labels."app.kubernetes.io/name" = "spliit";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "spliit";
          template = {
            metadata.labels."app.kubernetes.io/name" = "spliit";
            spec = {
              containers = [
                {
                  name = "spliit";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 3000; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      spliit-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "spliit";
          labels."app.kubernetes.io/name" = "spliit";
        };
        spec = {
          selector."app.kubernetes.io/name" = "spliit";
          ports = [
            {
              port = 3000;
              targetPort = 3090;
            }
          ];
        };
      };
      spliit-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "spliit";
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
                    path = "/spliit";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "spliit";
                        port.number = 3090;
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
