{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageConfig = {
    imageName = "ghcr.io/gethomepage/homepage";
    imageDigest = "sha256:7fa7b07a26bd8d90a44bb975c6455b10d8dee467ce674b040750ffb4a0f486d6";
    hash = "sha256-CewMt2VZ+4Z2zQ6c52ovciCdKqXckDdp4oFydqQD3Sk=";
    finalImageName = "ghcr.io/gethomepage/homepage";
    finalImageTag = "v1.9.0";
  };
  image = pkgs.dockerTools.pullImage imageConfig // {
    arch = "amd64";
  };
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
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
      homepage-config.content = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "homepage";
          labels."app.kubernetes.io/name" = "homepage";
        };
        data = {
          "bookmarks.yaml" = "";
          "custom.css" = "";
          "custom.js" = "";
          "docker.yaml" = "";
          "kubernetes.yaml" = ''
            mode: cluster
          '';
          "proxmox.yaml" = "";
          "services.yaml" = ''
            - iLO:
              - cap-apollo-ilo01:
                  href: https://192.168.1.45
              - cap-apollo-ilo02:
                  href: https://192.168.1.46
              - cap-apollo-ilo03:
                  href: https://192.168.1.47
              - cap-apollo-ilo04:
                  href: https://192.168.1.48
          '';
          "settings.yaml" = ''
            background: https://images.unsplash.com/photo-1502790671504-542ad42d5189?auto=format&fit=crop&w=2560&q=80
            cardBlur: md
            theme: dark
            color: slate
            headerStyle: boxedWidgets
            providers:
              longhorn:
                url: http://longhorn-frontend.longhorn-system.svc.cluster.local
          '';
          "widgets.yaml" = ''
            - kubernetes:
                cluster:
                  show: true
                  cpu: true
                  memory: true
                  showLabel: true
                  label: "cluster"
                nodes:
                  show: true
                  cpu: true
                  memory: true
                  showLabel: true
            - longhorn:
                expanded: true
                total: true
                labels: true
                nodes: true
            - datetime:
                text_size: xl
                format:
                  timeStyle: short
          '';
        };
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

          selector.matchLabels."app.kubernetes.io/name" = "homepage";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "homepage";
              annotations = {
                "diun.enable" = "true";
                "diun.watch_repo" = "true";
                "diun.sort_tags" = "semver";
                "diun.max_tags" = "5";
                "diun.include_tags" = "${imageConfig.finalImageTag};^[0-9].[0-9].[0-9]$";
              };
            };
            spec = {
              serviceAccountName = "homepage";
              automountServiceAccountToken = true;
              dnsPolicy = "ClusterFirst";
              enableServiceLinks = true;

              restartPolicy = "Always";

              containers = [
                {
                  name = "homepage";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "TZ";
                      value = "America/Los_Angeles";
                    }
                    {
                      name = "HOMEPAGE_ALLOWED_HOSTS";
                      value = "homepage.perren.cloud,homepage.internal.perren.cloud";
                    }
                    {
                      name = "LOG_TARGETS";
                      value = "stdout";
                    }
                  ];
                  ports = [ { containerPort = 3000; } ];
                  volumeMounts = [
                    {
                      mountPath = "/app/config/bookmarks.yaml";
                      name = "homepage-config";
                      subPath = "bookmarks.yaml";
                    }
                    {
                      mountPath = "/app/config/custom.css";
                      name = "homepage-config";
                      subPath = "custom.css";
                    }
                    {
                      mountPath = "/app/config/custom.js";
                      name = "homepage-config";
                      subPath = "custom.js";
                    }
                    {
                      mountPath = "/app/config/docker.yaml";
                      name = "homepage-config";
                      subPath = "docker.yaml";
                    }
                    {
                      mountPath = "/app/config/kubernetes.yaml";
                      name = "homepage-config";
                      subPath = "kubernetes.yaml";
                    }
                    {
                      mountPath = "/app/config/proxmox.yaml";
                      name = "homepage-config";
                      subPath = "proxmox.yaml";
                    }
                    {
                      mountPath = "/app/config/services.yaml";
                      name = "homepage-config";
                      subPath = "services.yaml";
                    }
                    {
                      mountPath = "/app/config/settings.yaml";
                      name = "homepage-config";
                      subPath = "settings.yaml";
                    }
                    {
                      mountPath = "/app/config/widgets.yaml";
                      name = "homepage-config";
                      subPath = "widgets.yaml";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "homepage-config";
                  configMap.name = "homepage";
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
            {
              host = "homepage.perren.cloud";
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
