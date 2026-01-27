{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "docker.gitea.com/gitea";
    imageDigest = "sha256:17d18218be2dad1f8ed402a4f906989505c90ab8b66ee9befcecfb5d470133e7";
    hash = "sha256-7Di5+jS9aL4asL94kuxNrZnN/zPpUMrjvJURaEtZy80=";
    finalImageName = "docker.gitea.com/gitea";
    finalImageTag = "1.25.4";
  };
  postgresServiceCfg = config.services.k3s.manifests.postgres-service.content;
  postgresServiceName = postgresServiceCfg.metadata.name;
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  sops = {
    secrets = {
      "postgres/environment/POSTGRES_USER".sopsFile = ../../../secrets/apollo-2000.yaml;
      "postgres/environment/POSTGRES_PASSWORD".sopsFile = ../../../secrets/apollo-2000.yaml;
    };

    templates.gitea-environment-secret = {
      content = builtins.toJSON {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "gitea-environment-secret";
          labels."app.kubernetes.io/name" = "gitea";
        };
        stringData = {
          GITEA__database__USER = config.sops.placeholder."postgres/environment/POSTGRES_USER";
          GITEA__database__PASSWD = config.sops.placeholder."postgres/environment/POSTGRES_PASSWORD";
        };
      };
      path = "/var/lib/rancher/k3s/server/manifests/gitea-environment-secret.yaml";
    };
  };
  services.k3s = {
    images = [ image ];
    manifests = {
      gitea-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "gitea";
          labels."app.kubernetes.io/name" = "gitea";
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

          selector.matchLabels."app.kubernetes.io/name" = "gitea";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "gitea";
              annotations."diun.enable" = "true";
            };
            spec = {
              securityContext.supplementalGroups = [ config.users.groups.nas-gitea-management.gid ];
              containers = [
                {
                  name = "gitea";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  envFrom = [ { secretRef.name = "gitea-environment-secret"; } ];
                  env = [
                    {
                      name = "TZ";
                      value = "America/Los_Angeles";
                    }
                    {
                      name = "GITEA__database__DB_TYPE";
                      value = "postgres";
                    }
                    {
                      name = "GITEA__database__HOST";
                      value = "${postgresServiceName}.default.svc.cluster.local";
                    }
                    {
                      name = "GITEA__database__NAME";
                      value = "gitea";
                    }
                    {
                      name = "GITEA__server__HTTP_PORT";
                      value = "30008";
                    }
                    {
                      name = "GITEA__server__PROTOCOL";
                      value = "http";
                    }
                    {
                      name = "GITEA__server__ROOT_URL";
                      value = "https://gitea.perren.cloud/";
                    }
                    {
                      name = "GITEA__server__SSH_LISTEN_PORT";
                      value = "30009";
                    }
                    {
                      name = "GITEA__server__SSH_PORT";
                      value = "30009";
                    }
                    {
                      name = "USER_UID";
                      value = "0";
                    }
                    {
                      name = "USER_GID";
                      value = "0";
                    }
                  ];
                  ports = [ { containerPort = 30008; } ];
                  volumeMounts = [
                    {
                      mountPath = "/data";
                      name = "data";
                    }
                    {
                      mountPath = "/config";
                      name = "config";
                    }
                    {
                      mountPath = "/tmp/gitea";
                      name = "tmp";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "config";
                  persistentVolumeClaim.claimName = "gitea-config-pvc";
                }
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "gitea-data-pvc";
                }
                {
                  name = "tmp";
                  emptyDir = { };
                }
              ];
            };
          };
        };
      };
      gitea-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "gitea-config-pvc";
          labels."app.kubernetes.io/name" = "gitea";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "10Mi";
        };
      };
      gitea-data-nfs-pv.content = {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "gitea-data-nfs-pv";
          labels."app.kubernetes.io/name" = "gitea";
        };
        spec = {
          capacity.storage = "1Ti";
          accessModes = [ "ReadOnlyMany" ];
          persistentVolumeReclaimPolicy = "Retain";
          mountOptions = [
            "nfsvers=4.1"
            "rsize=1048576"
            "wsize=1048576"
            "hard"
            "timeo=600"
            "retrans=2"
          ];
          nfs = {
            server = "cap-apollo-n01";
            path = "/nas_data_primary/gitea";
          };
        };
      };
      gitea-data-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "gitea-data-pvc";
          labels."app.kubernetes.io/name" = "gitea";
        };
        spec = {
          selector.matchLabels."app.kubernetes.io/name" = "gitea";
          accessModes = [ "ReadOnlyMany" ];
          volumeName = "gitea-data-nfs-pv";
          storageClassName = "";
          resources.requests.storage = "1Ti";
        };
      };
      gitea-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "gitea";
          labels."app.kubernetes.io/name" = "gitea";
        };
        spec = {
          selector."app.kubernetes.io/name" = "gitea";
          ports = [
            {
              port = 30008;
              targetPort = 30008;
            }
          ];
        };
      };
      gitea-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "gitea";
          labels."app.kubernetes.io/name" = "gitea";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Git and object repository";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Programming";
            "gethomepage.dev/icon" = "gitea.png";
            "gethomepage.dev/name" = "Gitea";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "gitea.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "gitea";
                        port.number = 30008;
                      };
                    };
                  }
                ];
              };
            }
            {
              host = "gitea.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "gitea";
                        port.number = 30008;
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
