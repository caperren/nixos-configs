{
  config,
  pkgs,
  lib,
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
  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
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
          strategy = {
            type = "RollingUpdate";
            rollingUpdate = {
              maxSurge = 0;
              maxUnavailable = 1;
            };
          };

          selector.matchLabels."app.kubernetes.io/name" = "technitium";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "technitium";
              annotations = {
                "diun.enable" = "true";
              };
            };
            spec = {
              securityContext = {
                sysctls = [
                  {
                    name = "net.ipv4.ip_local_port_range";
                    value = "1024 65535";
                  }
                ];
              };
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
                      value = "technitium.internal.perren.cloud";
                    }
                  ];
                  ports = [
                    {
                      name = "http";
                      containerPort = 5380;
                      protocol = "TCP";
                    }
                    {
                      name = "dns-tcp";
                      containerPort = 53;
                      protocol = "TCP";
                    }
                    {
                      name = "dns-udp";
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
      technitium-http-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "technitium-http-service";
          labels."app.kubernetes.io/name" = "technitium";
        };
        spec = {
          selector."app.kubernetes.io/name" = "technitium";
          sessionAffinity = "ClientIP";
          sessionAffinityConfig = {
            clientIP.timeoutSeconds = 300;
          };
          ports = [
            {
              name = "http";
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
          name = "technitium-dns-service";
          labels."app.kubernetes.io/name" = "technitium";
        };
        spec = {
          selector."app.kubernetes.io/name" = "technitium";
          type = "LoadBalancer";
          externalTrafficPolicy = "Local";
          ports = [
            {
              name = "dns-tcp";
              port = 53;
              targetPort = 53;
              protocol = "TCP";
            }
            {
              name = "dns-udp";
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
            "gethomepage.dev/description" = "DNS server and ad-blocker";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Cluster Management";
            "gethomepage.dev/icon" = "technitium.png";
            "gethomepage.dev/name" = "Technitium";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "technitium.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "technitium-http-service";
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
