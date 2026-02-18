{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "squat/generic-device-plugin";
    imageDigest = "sha256:d90c79cbc15174c5f81ce9133030b46005f45ae73e8489402acd0feb426d9930";
    hash = "sha256-ouURAX1gmg8AQKTsrPikXxUZnKJpikfJ8ofzO2t8fGo=";
    finalImageTag = "3a3a9e6";
    arch = "amd64";
  };
  zWaveUsbDevice =
    (builtins.elemAt config.services.k3s.manifests.zwave-js-ui-deployment.content.spec.template.spec.volumes 0)
    .hostPath.path;
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
    images = [ image ];
    manifests = {
      zwave-generic-device-plugin-config.content = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "zwave-generic-device-plugin-config";
          namespace = "kube-system";
        };
        data = {
          # This config tells the plugin to look for your dongle by the stable by-id symlink.
          # The "*" is important because the serial string portion varies.
          "config.yaml" = ''
            devices:
              - name: zwave
                groups:
                  - paths:
                      - path: ${zWaveUsbDevice}
          '';
        };
      };

      zwave-generic-device-plugin-daemonset.content = {
        apiVersion = "apps/v1";
        kind = "DaemonSet";
        metadata = {
          name = "zwave-generic-device-plugin";
          namespace = "kube-system";
          labels = {
            "app.kubernetes.io/name" = "zwave-generic-device-plugin";
          };
        };
        spec = {
          selector.matchLabels = {
            "app.kubernetes.io/name" = "zwave-generic-device-plugin";
          };

          template = {
            metadata.labels = {
              "app.kubernetes.io/name" = "zwave-generic-device-plugin";
            };

            spec = {
              # This needs host access to /dev and the kubelet device plugin socket dir.
              containers = [
                {
                  name = "generic-device-plugin";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";

                  args = [
                    "--config=/config/config.yaml"
                  ];

                  securityContext = {
                    privileged = true;
                  };

                  volumeMounts = [
                    {
                      name = "dev";
                      mountPath = "/dev";
                    }
                    {
                      name = "kubelet-device-plugins";
                      mountPath = "/var/lib/kubelet/device-plugins";
                    }
                    {
                      name = "config";
                      mountPath = "/config";
                      readOnly = true;
                    }
                  ];
                }
              ];

              volumes = [
                {
                  name = "dev";
                  hostPath = {
                    path = "/dev";
                  };
                }
                {
                  name = "kubelet-device-plugins";
                  hostPath = {
                    path = "/var/lib/kubelet/device-plugins";
                  };
                }
                {
                  name = "config";
                  configMap = {
                    name = "zwave-generic-device-plugin-config";
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
