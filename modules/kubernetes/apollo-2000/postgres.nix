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
    finalImageTag = "18.1";
    arch = "amd64";
  };
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  sops = {
    secrets = {
      "postgres/environment/POSTGRES_DB".sopsFile = ../../../secrets/apollo-2000.yaml;
      "postgres/environment/POSTGRES_USER".sopsFile = ../../../secrets/apollo-2000.yaml;
      "postgres/environment/POSTGRES_PASSWORD".sopsFile = ../../../secrets/apollo-2000.yaml;
    };

    templates.postgres-environment-secret = {
      content = builtins.toJSON {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "postgres-environment-secret";
          labels."app.kubernetes.io/name" = "postgres";
        };
        stringData = {
          POSTGRES_DB = config.sops.placeholder."postgres/environment/POSTGRES_DB";
          POSTGRES_USER = config.sops.placeholder."postgres/environment/POSTGRES_USER";
          POSTGRES_PASSWORD = config.sops.placeholder."postgres/environment/POSTGRES_PASSWORD";
        };
      };
      path = "/var/lib/rancher/k3s/server/manifests/postgres-environment-secret.yaml";
    };
  };

  services.k3s = {
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
          replicas = 1;
          strategy = {
            type = "RollingUpdate";
            rollingUpdate = {
              maxSurge = 0;
              maxUnavailable = 1;
            };
          };

          selector.matchLabels."app.kubernetes.io/name" = "postgres";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "postgres";
              annotations."diun.enable" = "true";
            };
            spec = {
              containers = [
                {
                  name = "postgres";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  envFrom = [ { secretRef.name = "postgres-environment-secret"; } ];
                  ports = [ { containerPort = 5432; } ];
                  volumeMounts = [
                    {
                      mountPath = "/var/lib/postgresql";
                      name = "data";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "postgres-data-pvc";
                }
              ];
            };
          };
        };
      };
      postgres-data-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "postgres-data-pvc";
          labels = {
            "app.kubernetes.io/name" = "postgres";
            "recurring-job.longhorn.io/source" = "enabled";
            "recurring-job.longhorn.io/backup-daily" = "enabled";
          };
        };
        spec = {
          accessModes = [ "ReadWriteMany" ];
          storageClassName = "longhorn";
          resources.requests.storage = "20Gi";
        };
      };
      postgres-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "postgres";
          labels."app.kubernetes.io/name" = "postgres";
        };
        spec = {
          selector."app.kubernetes.io/name" = "postgres";
          ports = [
            {
              port = 5432;
              targetPort = 5432;
            }
          ];
        };
      };
    };
  };
}
