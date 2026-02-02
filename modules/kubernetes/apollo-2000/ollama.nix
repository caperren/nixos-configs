{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "ollama/ollama";
    imageDigest = "sha256:2c9595c555fd70a28363489ac03bd5bf9e7c5bdf2890373c3a830ffd7252ce6d";
    hash = "sha256-tmBOo9DduFkNPCHKNL5XdhnQVjWNklo8GMe4rHA0fMg=";
    finalImageTag = "0.13.5";
    arch = "amd64";
  };
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
    images = [ image ];
    manifests = {
      ollama-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "ollama";
          labels."app.kubernetes.io/name" = "ollama";
        };
        spec = {
          replicas = 0;
          strategy = {
            type = "RollingUpdate";
            rollingUpdate = {
              maxSurge = 0;
              maxUnavailable = 1;
            };
          };

          selector.matchLabels."app.kubernetes.io/name" = "ollama";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "ollama";
              annotations."diun.enable" = "true";
            };
            spec = {
              containers = [
                {
                  name = "ollama";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  #                  envFrom = [ { secretRef.name = "ollama-environment-secret"; } ];
                  ports = [ { containerPort = 11434; } ];
                  resources = {
                    requests = {
                      memory = "16Gi";
                      cpu = "8000m";
                    };
                    limits = {
                      memory = "80Gi";
                      cpu = "28000m";
                    };
                  };
                  volumeMounts = [
                    {
                      mountPath = "/root/.ollama";
                      name = "data";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "ollama-data-pvc";
                }
              ];
            };
          };
        };
      };
      ollama-data-nfs-pv.content = {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "ollama-data-nfs-pv";
          labels."app.kubernetes.io/name" = "jellyfin";
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
            path = "/nas_data_high_speed/ollama";
          };
        };
      };
      ollama-data-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "ollama-data-pvc";
          labels."app.kubernetes.io/name" = "jellyfin";
        };
        spec = {
          selector.matchLabels."app.kubernetes.io/name" = "jellyfin";
          accessModes = [ "ReadOnlyMany" ];
          volumeName = "ollama-data-nfs-pv";
          storageClassName = "";
          resources.requests.storage = "1Ti";
        };
      };
      ollama-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "ollama";
          labels."app.kubernetes.io/name" = "ollama";
        };
        spec = {
          selector."app.kubernetes.io/name" = "ollama";
          ports = [
            {
              port = 11434;
              targetPort = 11434;
            }
          ];
        };
      };
    };
  };
}
