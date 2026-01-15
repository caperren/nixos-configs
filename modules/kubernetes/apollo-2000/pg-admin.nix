{
  config,
  pkgs,
  lib,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "dpage/pgadmin4";
    imageDigest = "sha256:50700ac17936d0227f9e3e4bb086a91efb67064debc4b4737c35545bf1564088";
    hash = "sha256-+Y0/YvJ93hpnsL+XM3ipo+CsKueYZ6TU1ysP+Sai46U=";
    finalImageTag = "9.11.0";
    arch = "amd64";
  };
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  sops = {
    secrets."pg-admin/environment/PGADMIN_DEFAULT_PASSWORD".sopsFile = ../../../secrets/apollo-2000.yaml;

    templates.pg-admin-environment-secret = {
      content = builtins.toJSON {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "pg-admin-environment-secret";
          labels."app.kubernetes.io/name" = "pg-admin";
        };
        stringData.PGADMIN_DEFAULT_PASSWORD = config.sops.placeholder."pg-admin/environment/PGADMIN_DEFAULT_PASSWORD";
      };
      path = "/var/lib/rancher/k3s/server/manifests/pg-admin-environment-secret.yaml";
    };
  };

  services.k3s = {
    images = [ image ];
    manifests = {
      pg-admin-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "pg-admin";
          labels."app.kubernetes.io/name" = "pg-admin";
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

          selector.matchLabels."app.kubernetes.io/name" = "pg-admin";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "pg-admin";
              annotations."diun.enable" = "true";
            };
            spec = {
              containers = [
                {
                  name = "pg-admin";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  envFrom = [ { secretRef.name = "pg-admin-environment-secret"; } ];
                  env = [
                    {
                      name = "PGADMIN_DEFAULT_EMAIL";
                      value = "caperren@gmail.com";  # FIXME: factor this out
                    }
                  ];
                  ports = [ { containerPort = 80; } ];
                  volumeMounts = [ ];
                }
              ];
              volumes = [ ];
            };
          };
        };
      };
      pg-admin-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "pg-admin";
          labels."app.kubernetes.io/name" = "pg-admin";
        };
        spec = {
          selector."app.kubernetes.io/name" = "pg-admin";
          ports = [
            {
              port = 80;
              targetPort = 80;
            }
          ];
        };
      };
      pg-admin-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "pg-admin";
          labels."app.kubernetes.io/name" = "pg-admin";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Postgres admin ui";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Database Management";
            "gethomepage.dev/icon" = "pgadmin.png";
            "gethomepage.dev/name" = "pgAdmin";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "pg-admin.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "pg-admin";
                        port.number = 80;
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
