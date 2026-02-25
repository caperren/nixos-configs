{
  config,
  pkgs,
  lib,
  ...
}:
let
  immichServerImage = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/immich-app/immich-server";
    imageDigest = "sha256:aa163d2e1cc2b16a9515dd1fef901e6f5231befad7024f093d7be1f2da14341a";
    hash = "sha256-VRqUD6mVub5qoIL6zt5iy4jk7rBm6Y4ddU/+o724q2g=";
    finalImageName = "ghcr.io/immich-app/immich-server";
    finalImageTag = "v2.5.6";
  };
  immichPostgresImage = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/immich-app/postgres";
    imageDigest = "sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
    hash = "sha256-YNxadMZRLd2Wky6UvZFTcJ+KXFxg51E4zPdEAG7HtPk=";
    finalImageName = "ghcr.io/immich-app/postgres";
    finalImageTag = "14-vectorchord0.4.3-pgvectors0.2.0";
  };
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
    images = [ immichServerImage immichPostgresImage ];
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
