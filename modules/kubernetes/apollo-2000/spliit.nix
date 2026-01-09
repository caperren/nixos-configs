{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/spliit-app/spliit";
    imageDigest = "sha256:2f0f44d58768bed6c7c9aed72f74e43a14599b459828cd87227a7c35ba29b9b8";
    hash = "sha256-yHjOZwJeLvYk/WvprkwcW4QmVsYsbGPmY8D00OnazYY=";
    finalImageTag = "1.19.0";
    arch = "amd64";
  };

  postgresImageName =
    (builtins.elemAt config.services.k3s.manifests.postgres-deployment.content.spec.template.spec.containers 0)
    .image;
  postgresServiceCfg = config.services.k3s.manifests.postgres-service.content;
  postgresServiceName = postgresServiceCfg.metadata.name;
  postgresServicePort = toString (builtins.elemAt postgresServiceCfg.spec.ports 0).port;
  spliitDbName = "spliit";
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  sops = {
    secrets = {
      "postgres/environment/POSTGRES_USER".sopsFile = ../../../secrets/apollo-2000.yaml;
      "postgres/environment/POSTGRES_PASSWORD".sopsFile = ../../../secrets/apollo-2000.yaml;
    };

    templates.spliit-init-db-environment-secret = {
      content = builtins.toJSON {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "spliit-init-db-environment-secret";
          labels."app.kubernetes.io/name" = "spliit";
        };
        stringData = {
          POSTGRES_HOST = "${postgresServiceName}.default.svc.cluster.local";
          POSTGRES_PORT = postgresServicePort;
          POSTGRES_DB = spliitDbName;
          POSTGRES_USER = config.sops.placeholder."postgres/environment/POSTGRES_USER";
          POSTGRES_PASSWORD = config.sops.placeholder."postgres/environment/POSTGRES_PASSWORD";
        };
      };
      path = "/var/lib/rancher/k3s/server/manifests/spliit-init-db-environment-secret.yaml";
    };

    templates.spliit-environment-secret = {
      content = builtins.toJSON {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "spliit-environment-secret";
          labels."app.kubernetes.io/name" = "spliit";
        };
        stringData = {
          POSTGRES_URL_NON_POOLING = "postgresql://${
            config.sops.placeholder."postgres/environment/POSTGRES_USER"
          }:${
            config.sops.placeholder."postgres/environment/POSTGRES_PASSWORD"
          }@${postgresServiceName}.default.svc.cluster.local/${spliitDbName}";
          POSTGRES_PRISMA_URL = "postgresql://${
            config.sops.placeholder."postgres/environment/POSTGRES_USER"
          }:${
            config.sops.placeholder."postgres/environment/POSTGRES_PASSWORD"
          }@${postgresServiceName}.default.svc.cluster.local/${spliitDbName}";
        };
      };
      path = "/var/lib/rancher/k3s/server/manifests/spliit-environment-secret.yaml";
    };
  };

  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    images = [ image ];
    manifests = {
      spliit-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "spliit";
          labels."app.kubernetes.io/name" = "spliit";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "spliit";
          template = {
            metadata.labels."app.kubernetes.io/name" = "spliit";
            spec = {
              initContainers = [
                {
                  name = "init-create-db";
                  image = postgresImageName;
                  envFrom = [ { secretRef.name = "spliit-init-db-environment-secret"; } ];
                  command = [
                    "sh"
                    "-ec"
                  ];
                  args = [
                    ''
                      export PGHOST="$POSTGRES_HOST"
                      export PGPORT="$POSTGRES_PORT"
                      export PGUSER="$POSTGRES_USER"
                      export PGPASSWORD="$POSTGRES_PASSWORD"
                      export PGDATABASE="postgres"

                      echo "Waiting for Postgres at $PGHOST:$PGPORT..."
                      until pg_isready; do
                        sleep 2
                      done

                      echo "Ensuring database '$POSTGRES_DB' exists..."
                      if psql -tAc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB';" | grep -q 1; then
                        echo "Database '$POSTGRES_DB' already exists."
                      else
                        echo "Creating database '$POSTGRES_DB'..."
                        psql -v ON_ERROR_STOP=1 -c "CREATE DATABASE \"$POSTGRES_DB\";"
                      fi
                    ''
                  ];
                }
              ];
              containers = [
                {
                  name = "spliit";
                  image = "${image.imageName}:${image.imageTag}";
                  envFrom = [ { secretRef.name = "spliit-environment-secret"; } ];
                  env = [
                    {
                      name = "TZ";
                      value = "America/Los_Angeles";
                    }
                  ];
                  ports = [ { containerPort = 3000; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      spliit-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "spliit";
          labels."app.kubernetes.io/name" = "spliit";
        };
        spec = {
          selector."app.kubernetes.io/name" = "spliit";
          ports = [
            {
              port = 3000;
              targetPort = 3000;
            }
          ];
        };
      };
      spliit-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "spliit";
          labels."app.kubernetes.io/name" = "spliit";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Split expenses";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Financial";
            "gethomepage.dev/icon" = "spliit.png";
            "gethomepage.dev/name" = "Spliit";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "spliit.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "spliit";
                        port.number = 3000;
                      };
                    };
                  }
                ];
              };
            }
            {
              host = "spliit.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "spliit";
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
