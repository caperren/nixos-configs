{
  config,
  pkgs,
  ...
}:
let
  image = pkgs.dockerTools.pullImage {
    imageName = "technitium/dns-server";
    imageDigest = "sha256:322b236403ca25028032f28736e2270a860527b030b162c9f82451c6494c4698";
    hash = "sha256-/hAQyui0O4535jm2qaVmkY7w6SmCARg3sbKbb06UeRc=";
    finalImageTag = "14.3.0";
    arch = "amd64";
  };
in
{
  services.k3s = {
    images = [ image ];
    manifests = {
      technitium-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "technitium";
          labels."app.kubernetes.io/name" = "technitium";
        };
        spec = {
          replicas = 1;
          selector.matchLabels."app.kubernetes.io/name" = "technitium";

          securityContext = {
            sysctls = [
              {
                name = "net.ipv4.ip_local_port_range";
                value = "1024 65535";
              }
            ];
          };

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "technitium";
              annotations = {
                "diun.enable" = "true";
              };
            };
            spec = {
              containers = [
                {
                  name = "technitium";
                  image = "${image.imageName}:${image.imageTag}";
                  env = [
                    {
                      name = "TZ";
                      value = "America/Los_Angeles";
                    }
                    {
                      name = "DNS_SERVER_DOMAIN";
                      value = "perren.local";
                    }
                  ];
                  ports = [
                    { containerPort = 5380; }
                    {
                      containerPort = 53;
                      protocol = "TCP";
                    }
                    {
                      containerPort = 53;
                      protocol = "UDP";
                    }
                  ];
                  volumeMounts = [
                    {
                      mountPath = "/etc/dns";
                      name = "config";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "config";
                  persistentVolumeClaim.claimName = "technitium-config-pvc";
                }
              ];
            };
          };
        };
      };
      technitium-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "technitium-config-pvc";
          labels."app.kubernetes.io/name" = "technitium";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "1Gi";
        };
      };
      technitium-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "technitium";
          labels."app.kubernetes.io/name" = "technitium";
        };
        spec = {
          selector."app.kubernetes.io/name" = "technitium";
          ports = [
            {
              port = 5380;
              targetPort = 5380;
            }
          ];
        };
      };
      technitium-dns-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "technitium";
          labels."app.kubernetes.io/name" = "technitium";
        };
        spec = {
          selector."app.kubernetes.io/name" = "technitium";
          type = "LoadBalancer";
          ports = [
            {
              port = 53;
              targetPort = 53;
              protocol = "TCP";
            }
            {
              port = 53;
              targetPort = 53;
              protocol = "UDP";
            }
          ];
        };
      };
      technitium-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "technitium";
          labels."app.kubernetes.io/name" = "technitium";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "technitium.perren.local";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "technitium";
                        port.number = 5380;
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
