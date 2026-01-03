{
  config,
  pkgs,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "docker.gitea.com/gitea";
    imageDigest = "sha256:fee0e5e55da6d2d11186bf39023a772fe63d9deffc0a83283e3d8e5d11c2716a";
    hash = "sha256-3PzTVd34AmeRoZrvc1zKkXiZN/ZeXOObumYrGO9FR1Y=";
    finalImageTag = "1.25.3";
    arch = "amd64";
  };
in
{
  services.k3s = {
    images = [ image ];
    manifests = {
      gitea-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "gitea";
          labels."app.kubernetes.io/name" = "gitea";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "gitea";
          template = {
            metadata.labels."app.kubernetes.io/name" = "gitea";
            spec = {
              containers = [
                {
                  name = "gitea";
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
      gitea-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "gitea";
          labels."app.kubernetes.io/name" = "gitea";
        };
        spec = {
          selector."app.kubernetes.io/name" = "gitea";
          ports = [
            {
              port = 3000;
              targetPort = 3000;
            }
          ];
        };
      };
      gitea-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "gitea";
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
                    path = "/gitea";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "gitea";
                        port.number = 3000;
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
