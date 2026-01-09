{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "postgres";
    imageDigest = "sha256:bfe50b2b0ddd9b55eadedd066fe24c7c6fe06626185b73358c480ea37868024d";
    hash = "sha256-kABeg+78cZ1caggEV2i/2EJz5omlbiD3rDjzJddwlbU=";
    finalImageName = "postgres";
    finalImageTag = "18.1";
    arch = "amd64";
  };
in
{
#  sops = {
#    secrets."postgres/".sopsFile = ../../../secrets/apollo-2000.yaml;
#    templates.hetznerDdnsConfig = {
#      content = builtins.toJSON {
#        apiVersion = "v1";
#        kind = "Secret";
#        metadata = {
#          name = "hetzner-ddns-config";
#          labels."app.kubernetes.io/name" = "hetzner-ddns";
#        };
#        data.config = config.sops.placeholder."hetzner-ddns/config";
#      };
#      path = "/var/lib/rancher/k3s/server/manifests/hetzner-ddns-config-secret.yaml";
#    };
#  };


  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    images = [ image ];
    manifests = {
      postgres-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "postgres";
          labels."app.kubernetes.io/name" = "postgres";
        };
        spec = {
          replicas = 3;
          selector.matchLabels."app.kubernetes.io/name" = "postgres";
          template = {
            metadata.labels."app.kubernetes.io/name" = "postgres";
            spec = {
              containers = [
                {
                  name = "postgres";
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
