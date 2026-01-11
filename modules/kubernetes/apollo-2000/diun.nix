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
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  sops = {
    secrets = {
      "bots/perrencloudbot/api-token".sopsFile = ../../../secrets/default.yaml;
      "bots/perrencloudbot/chat-ids".sopsFile = ../../../secrets/default.yaml;
    };

    templates.diun-environment-secret = {
      content = builtins.toJSON {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "diun-environment-secret";
          labels."app.kubernetes.io/name" = "diun";
        };
        stringData = {
          DIUN_NOTIF_TELEGRAM_TOKEN = config.sops.placeholder."bots/perrencloudbot/api-token";
          DIUN_NOTIF_TELEGRAM_CHATIDS = config.sops.placeholder."bots/perrencloudbot/chat-ids";
        };
      };
      path = "/var/lib/rancher/k3s/server/manifests/diun-environment-secret.yaml";
    };
  };

  services.k3s = {
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
              annotations."diun.enable" = "true";
            };
            spec = {
              serviceAccountName = "diun";

              restartPolicy = "Always";

              containers = [
                {
                  name = "diun";
                  image = "${image.imageName}:${image.imageTag}";
                  args = [ "serve" ];
                  envFrom = [ { secretRef.name = "diun-environment-secret"; } ];
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
                      name = "DIUN_NOTIF_TELEGRAM_TEMPLATEBODY";
                      value = "*{{ if (eq .Entry.Status \"new\") }}New{{ else }}Updated{{ end }} Application Tag Available*\n\n_Name_:  {{ if .Entry.Image.HubLink }}[{{ .Entry.Manifest.Name }}]({{ .Entry.Image.HubLink }}){{ else }}{{ .Entry.Manifest.Name }}{{ end }}\n_Tag_:      {{ .Entry.Image.Tag }}{{ if .Meta.URL }}\n_Repo_:   {{ .Meta.URL }}{{ else }}{{ end }}\n\n```bash\nnix-shell -p nix-prefetch-docker --run \"nix-prefetch-docker --image-name {{ .Entry.Image }} --image-tag {{ .Entry.Image.Tag }}\"\n```";
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
