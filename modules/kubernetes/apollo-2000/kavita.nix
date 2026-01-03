{
  config,
  pkgs,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/kareadita/kavita";
    imageDigest = "sha256:22c42f3cc83fb98b98a6d6336200b615faf2cfd2db22dab363136744efda1bb0";
    hash = "sha256-bV14IPTxlQ18ujzjfxR6DZP41xSDlqz1iX/BBAAPP1E=";
    finalImageTag = "0.8.8";
    arch = "amd64";
  };
in
{
  services.k3s = {
    images = [ image ];
    manifests = {
      kavita-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "kavita";
          labels."app.kubernetes.io/name" = "kavita";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "kavita";
          template = {
            metadata.labels."app.kubernetes.io/name" = "kavita";
            spec = {
              containers = [
                {
                  name = "kavita";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 5000; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      kavita-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "kavita";
          labels."app.kubernetes.io/name" = "kavita";
        };
        spec = {
          selector."app.kubernetes.io/name" = "kavita";
          ports = [
            {
              port = 5000;
              targetPort = 5000;
            }
          ];
        };
      };
      kavita-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "kavita";
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
                    path = "/kavita";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "kavita";
                        port.number = 5000;
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
