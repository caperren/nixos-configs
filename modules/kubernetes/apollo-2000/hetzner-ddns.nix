{
  config,
  pkgs,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "filiparag/hetzner_ddns";
    imageDigest = "sha256:5a9cbae7997ca297f770148e03cf56d90c6aae00e8ecef88e348ad13ca8a9341";
    hash = "sha256-3/+eyeI23bJznxchBaqLEBzPEDn+NMXLet5OqElsmG8=";
    finalImageTag = "1.0.1";
    arch = "amd64";
  };
in
{
  services.k3s = {
    images = [ image ];
    manifests = {
      hetzner-ddns-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "hetzner-ddns";
          labels."app.kubernetes.io/name" = "hetzner-ddns";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "hetzner-ddns";
          template = {
            metadata.labels."app.kubernetes.io/name" = "hetzner-ddns";
            spec = {
              containers = [
                {
                  name = "hetzner-ddns";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [ ];
                  ports = [ ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
    };
  };
}
