{
  config,
  pkgs,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/autobrr/autobrr";
    imageDigest = "sha256:db9794958a0f9db93059c1e9f06193a063ce3846d346d7a7c9eca607c6617c51";
    hash = "sha256-jURgYHuQOQBCm7h+S11e9e8RbB/ufqu4FuOrVjJlqPc=";
    finalImageTag = "v1.71";
    arch = "amd64";
  };
in
{
  services.k3s = {
    images = [ image ];
    manifests = {
      autobrr-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "autobrr";
          labels."app.kubernetes.io/name" = "autobrr";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "autobrr";
          template = {
            metadata.labels."app.kubernetes.io/name" = "autobrr";
            spec = {
              containers = [
                {
                  name = "autobrr";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 7474; } ];
                  volumeMounts = [ ];
                }
              ];

              volumes = [ ];
            };
          };
        };
      };
      autobrr-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "autobrr";
          labels."app.kubernetes.io/name" = "autobrr";
        };
        spec = {
          selector."app.kubernetes.io/name" = "autobrr";
          ports = [
            {
              port = 7474;
              targetPort = 7474;
            }
          ];
        };
      };
      autobrr-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "autobrr";
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
                    path = "/autobrr";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "autobrr";
                        port.number = 7474;
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
