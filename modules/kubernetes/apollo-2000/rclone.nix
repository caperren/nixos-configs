{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "rclone/rclone";
    imageDigest = "sha256:0eb18825ac9732c21c11d654007170572bbd495352bb6dbb624f18e4f462c496";
    hash = "sha256-5D4odjC7FcZkPUdta1AykkTZ3gkTEp5YSV6Rx24cJdU=";
    finalImageTag = "1.72.0";
    arch = "amd64";
  };
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02"){
    images = [ image ];
    manifests = {
      rclone-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "rclone";
          labels."app.kubernetes.io/name" = "rclone";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "rclone";
          template = {
            metadata.labels."app.kubernetes.io/name" = "rclone";
            spec = {
              containers = [
                {
                  name = "rclone";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
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
