{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/immich-app/immich-server";
    imageDigest = "sha256:e6a6298e67ae077808fdb7d8d5565955f60b0708191576143fc02d30ab1389d1";
    hash = "sha256-iB92wUlMfsWuWjuv87Gc6HbWl1PzZl89jgoCveix1JA=";
    finalImageTag = "v2.4.1";
    arch = "amd64";
  };
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
    images = [ image ];
    manifests = {
      immich-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "immich";
          labels."app.kubernetes.io/name" = "immich";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "immich";
          template = {
            metadata.labels."app.kubernetes.io/name" = "immich";
            spec = {
              containers = [
                {
                  name = "immich";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "IMMICH_PORT";
                      value = "2283";
                    }
                  ];
                  ports = [ { containerPort = 2283; } ];
                  volumeMounts = [ ];
                }
              ];
              hostNetwork = true;
              volumes = [ ];
            };
          };
        };
      };
      immich-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "immich";
          labels."app.kubernetes.io/name" = "immich";
        };
        spec = {
          selector."app.kubernetes.io/name" = "immich";
          ports = [
            {
              port = 2283;
              targetPort = 2283;
            }
          ];
        };
      };
      immich-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "immich";
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
                    path = "/immich";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "immich";
                        port.number = 2283;
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
