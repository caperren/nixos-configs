{
  config,
  pkgs,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "technitium/dns-server";
    imageDigest = "sha256:322b236403ca25028032f28736e2270a860527b030b162c9f82451c6494c4698";
    hash = "sha256-/hAQyui0O4535jm2qaVmkY7w6SmCARg3sbKbb06UeRc=";
    finalImageTag = "14.3.0";
    arch = "amd64";
  };
in
{
  services.k3s = {
    images = [ image ];
    manifests = {
      technitium-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "technitium";
          labels."app.kubernetes.io/name" = "technitium";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "technitium";
          template = {
            metadata.labels."app.kubernetes.io/name" = "technitium";
            spec = {
              containers = [
                {
                  name = "technitium";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 5380; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      technitium-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "technitium";
          labels."app.kubernetes.io/name" = "technitium";
        };
        spec = {
          selector."app.kubernetes.io/name" = "technitium";
          ports = [
            {
              port = 5380;
              targetPort = 5380;
            }
          ];
        };
      };
      technitium-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "technitium";
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
                    path = "/technitium";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "technitium";
                        port.number = 5380;
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
