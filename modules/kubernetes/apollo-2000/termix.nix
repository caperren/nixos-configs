{
  config,
  pkgs,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/lukegus/termix";
    imageDigest = "sha256:32e600034382d80dc883e1bea550cc2a171c15401c3b6494cee81009abc36533";
    hash = "sha256-q9zA6O0ofintLPFVvljtU2Ixn/+55m6jS+WTRlqSV3k=";
    finalImageTag = "release-1.10.0";
    arch = "amd64";
  };
in
{
  services.k3s = {
    images = [ image ];
    manifests = {
      termix-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "termix";
          labels."app.kubernetes.io/name" = "termix";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "termix";

          # Uses node as a base, with groupId 1000
          securityContext = {
            fsGroup = 1000;
          };

          template = {
            metadata.labels."app.kubernetes.io/name" = "termix";
            spec = {
              containers = [
                {
                  name = "termix";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ { containerPort = 8080; } ];
                  volumeMounts = [
                    {
                      mountPath = "/app/data";
                      name = "data";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "termix-data-pvc";
                }
              ];
            };
          };
        };
      };
      termix-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "termix";
          labels."app.kubernetes.io/name" = "termix";
        };
        spec = {
          selector."app.kubernetes.io/name" = "termix";
          ports = [
            {
              port = 8080;
              targetPort = 30000;
            }
          ];
        };
      };
      termix-data-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "termix-data-pvc";
          labels."app.kubernetes.io/name" = "termix";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "1Gi";
        };
      };
      termix-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "termix";
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
                    host = "termix.perren.local";
                    backend = {
                      service = {
                        name = "termix";
                        port.number = 30000;
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
