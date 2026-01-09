{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/crazy-max/diun";
    imageDigest = "sha256:3e277cd1f1262fe6ff1047e5550f6f2e1c860c3c60b0058625e3c69888a4cc8d";
    hash = "sha256-skI6pLbZ2E1xzrI7AnlFmcHP4HbbwbAhjaObbrI4/7Y=";
    finalImageTag = "4.31.0";
    arch = "amd64";
  };
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    images = [ image ];
    manifests = {
      diun-serviceaccount.content = {
        apiVersion = "v1";
        kind = "ServiceAccount";
        metadata = {
          name = "diun";
          namespace = "default";
          labels."app.kubernetes.io/name" = "diun";
        };
      };
      diun-cluster-role.content = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRole";
        metadata = {
          name = "diun";
          labels."app.kubernetes.io/name" = "diun";
        };
        rules = [
          {
            apiGroups = [ "" ];
            resources = [
              "pods"
            ];
            verbs = [
              "get"
              "list"
              "watch"
            ];
          }
        ];
      };
      diun-cluster-role-binding.content = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRoleBinding";
        metadata = {
          name = "diun";
          labels."app.kubernetes.io/name" = "diun";
        };
        roleRef = {
          apiGroup = "rbac.authorization.k8s.io";
          kind = "ClusterRole";
          name = "diun";
        };
        subjects = [
          {
            kind = "ServiceAccount";
            name = "diun";
            namespace = "default";
          }
        ];
      };
      diun-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "diun";
          labels."app.kubernetes.io/name" = "diun";
        };
        spec = {
          replicas = 1;
          strategy = {
            type = "RollingUpdate";
            rollingUpdate = {
              maxSurge = 0;
              maxUnavailable = 1;
            };
          };

          selector.matchLabels."app.kubernetes.io/name" = "diun";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "diun";
              annotations = {
                "diun.enable" = "true";
              };
            };
            spec = {
              serviceAccountName = "diun";

              restartPolicy = "Always";

              containers = [
                {
                  name = "diun";
                  image = "${image.imageName}:${image.imageTag}";
                  args = [ "serve" ];
                  env = [
                    {
                      name = "TZ";
                      value = "America/Los_Angeles";
                    }
                    {
                      name = "LOG_LEVEL";
                      value = "debug";
                    }
                    {
                      name = "LOG_JSON";
                      value = "false";
                    }
                    {
                      name = "DIUN_WATCH_WORKERS";
                      value = "20";
                    }
                    {
                      name = "DIUN_WATCH_SCHEDULE";
                      value = "0 */6 * * *";
                    }
                    {
                      name = "DIUN_WATCH_JITTER";
                      value = "30s";
                    }
                    {
                      name = "DIUN_PROVIDERS_KUBERNETES";
                      value = "true";
                    }
                  ];
                  ports = [ { containerPort = 8080; } ];
                  volumeMounts = [
                    {
                      mountPath = "/data";
                      name = "data";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "diun-data-pvc";
                }
              ];
            };
          };
        };
      };
      diun-data-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "diun-data-pvc";
          labels."app.kubernetes.io/name" = "diun";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "1Gi";
        };
      };
    };
  };
}
