{
  config,
  pkgs,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/hotio/prowlarr";
    imageDigest = "sha256:3f057312483cb186fb27f2d46f683f29e1a95d6e108748012d7d3abe1ad8b2ca";
    hash = "sha256-WQoh9VSTFScyM9Z/w++q+SkMK5RWNH/AoYuG9ye3Js8=";
    finalImageTag = "release-2.3.0.5236";
    arch = "amd64";
  };
in
{
  services.k3s = {
    images = [ image ];
    manifests = {
      prowlaar-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "prowlaar";
          labels."app.kubernetes.io/name" = "prowlaar";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "prowlaar";
          template = {
            metadata.labels."app.kubernetes.io/name" = "prowlaar";
            spec = {
              containers = [
                {
                  name = "prowlaar";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 9696; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      prowlaar-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "prowlaar";
          labels."app.kubernetes.io/name" = "prowlaar";
        };
        spec = {
          selector."app.kubernetes.io/name" = "prowlaar";
          ports = [
            {
              port = 9696;
              targetPort = 9696;
            }
          ];
        };
      };
      prowlaar-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "prowlaar";
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
                    path = "/prowlaar";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "prowlaar";
                        port.number = 9696;
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
