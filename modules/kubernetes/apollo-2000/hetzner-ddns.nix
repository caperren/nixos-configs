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
  sops = {
    secrets."hetzner-ddns/config".sopsFile = ../../../secrets/apollo-2000.yaml;
    templates.hetznerDdnsConfig = {
      content = builtins.toJSON{
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "hetzner-ddns-config";
          labels."app.kubernetes.io/name" = "hetzner-ddns";
        };
        data.config = config.sops.placeholder."hetzner-ddns/config";
      };
      path = "/var/lib/rancher/k3s/server/manifests/hetzner-ddns-config-secret.yaml";
    };
  };

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
                  volumeMounts = [
                    {
                      name = "secret-config";
                      mountPath = "/etc/hetzner_ddns.json";
                      readOnly = true;
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "secret-config";
                  secret = {
                    secretName = "hetzner-ddns-config";
                    items = [
                    {
                        key = "config";
                        path = "/";
                    }
                    ];
                  };
                }
              ];
            };
          };
        };
      };
    };
  };
}
