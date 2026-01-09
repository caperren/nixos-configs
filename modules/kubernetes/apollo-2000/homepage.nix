{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/gethomepage/homepage";
    imageDigest = "sha256:7dc099d5c6ec7fc945d858218565925b01ff8a60bcbfda990fc680a8b5cd0b6e";
    hash = "sha256-S1c4oN+VH5GNrl44TchRRe6VhETUuvFp36XjJV8JbDs=";
    finalImageTag = "v1.8.0";
    arch = "amd64";
  };
in
{
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    images = [ image ];
    manifests = {
      homepage-serviceaccount.content = {
        apiVersion = "v1";
        kind = "ServiceAccount";
        metadata = {
          name = "homepage";
          namespace = "default";
          labels."app.kubernetes.io/name" = "homepage";
        };
        secrets = [
          {
            name = "homepage";
          }
        ];
      };
      homepage-serviceaccount-token-secret.content = {
        apiVersion = "v1";
        kind = "Secret";
        type = "kubernetes.io/service-account-token";
        metadata = {
          name = "homepage";
          namespace = "default";
          labels."app.kubernetes.io/name" = "homepage";
          annotations."kubernetes.io/service-account.name" = "homepage";
        };
      };
      homepage-config.content = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "homepage";
          labels."app.kubernetes.io/name" = "homepage";
        };
        data = {
          "kubernetes.yaml" = {
            mode = "cluster";
          };
        };
      };
      homepage-cluster-role.content = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRole";
        metadata = {
          name = "homepage";
          labels."app.kubernetes.io/name" = "homepage";
        };
        rules = [
          {
            apiGroups = [
              ""
            ];
            resources = [
              "namespaces"
              "pods"
              "nodes"
            ];
            verbs = [
              "get"
              "list"
            ];
          }
          {
            apiGroups = [
              "extensions"
              "networking.k8s.io"
            ];
            resources = [
              "ingresses"
            ];
            verbs = [
              "get"
              "list"
            ];
          }
          {
            apiGroups = [
              "traefik.io"
            ];
            resources = [
              "ingressroutes"
            ];
            verbs = [
              "get"
              "list"
            ];
          }
          {
            apiGroups = [
              "gateway.networking.k8s.io"
            ];
            resources = [
              "httproutes"
              "gateways"
            ];
            verbs = [
              "get"
              "list"
            ];
          }
          {
            apiGroups = [
              "metrics.k8s.io"
            ];
            resources = [
              "nodes"
              "pods"
            ];
            verbs = [
              "get"
              "list"
            ];
          }
        ];
      };
      homepage-cluster-role-binding.content = {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRoleBinding";
        metadata = {
          name = "homepage";
          labels."app.kubernetes.io/name" = "homepage";
        };
        roleRef = {
          apiGroup = "rbac.authorization.k8s.io";
          kind = "ClusterRole";
          name = "homepage";
        };
        subjects = [
          {
            kind = "ServiceAccount";
            name = "homepage";
            namespace = "default";
          }
        ];
      };
      homepage-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "homepage";
          labels."app.kubernetes.io/name" = "homepage";
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

          selector.matchLabels."app.kubernetes.io/name" = "homepage";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "homepage";
              annotations = {
                "homepage.enable" = "true";
              };
            };
            spec = {
              serviceAccountName = "homepage";
              containers = [
                {
                  name = "homepage";
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
                  ports = [ { containerPort = 3000; } ];
                  volumeMounts = [
                    {
                      mountPath = "/app/config/kubernetes.yaml";
                      name = "homepage-config";
                      subPath = "kubernetes.yaml";
                    }
                    {
                      mountPath = "/app/config/logs";
                      name = "logs";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "logs";
                  emptyDir = { };
                }
              ];
            };
          };
        };
      };
      homepage-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "homepage";
          labels."app.kubernetes.io/name" = "homepage";
        };
        spec = {
          selector."app.kubernetes.io/name" = "homepage";
          ports = [
            {
              port = 3000;
              targetPort = 3000;
            }
          ];
        };
      };
      homepage-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "homepage";
          labels."app.kubernetes.io/name" = "homepage";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Dynamically Detected Homepage";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Cluster Management";
            "gethomepage.dev/icon" = "homepage.png";
            "gethomepage.dev/name" = "Homepage";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "homepage.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "homepage";
                        port.number = 3000;
                      };
                    };
                  }
                ];
              };
            }
          ];
        };
      };
    };
  };
}
