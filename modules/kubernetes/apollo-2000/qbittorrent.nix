{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageConfig = {
    imageName = "linuxserver/qbittorrent";
    imageDigest = "sha256:b8a08ffba8850e2e71153e153cf5eed2dedbf499ef9b123262735ce924b65586";
    hash = "sha256-wn8kjR2P5XSk198uQYtxZMRDpjbL2Q/k1XEMpc91760=";
    finalImageName = "linuxserver/qbittorrent";
    finalImageTag = "5.1.4";
  };
  image = pkgs.dockerTools.pullImage imageConfig // {
    arch = "amd64";
  };

  allowedReplicas = if config."perren.cloud".maintenance.nfs then 0 else 1;
in
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
  services.k3s = {
    images = [ image ];
    manifests = {

      qbittorrent-deployment.content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "qbittorrent";
          labels."app.kubernetes.io/name" = "qbittorrent";
        };
        spec = {
          replicas = allowedReplicas;
          strategy = {
            type = "RollingUpdate";
            rollingUpdate = {
              maxSurge = 0;
              maxUnavailable = 1;
            };
          };

          selector.matchLabels."app.kubernetes.io/name" = "qbittorrent";

          template = {
            metadata = {
              labels."app.kubernetes.io/name" = "qbittorrent";
              annotations."diun.enable" = "true";
              annotations."k8s.v1.cni.cncf.io/networks" = "vlan5";
            };
            spec = {
              securityContext = {
                supplementalGroups = [ config.users.groups.nas-media-management.gid ];
              };
              initContainers = [
                {
                  name = "fix-multus-routes";
                  image = "busybox:1.36";
                  securityContext = {
                    capabilities.add = [ "NET_ADMIN" ];
                    runAsUser = 0;
                    runAsGroup = 0;
                  };
                  command = [
                    "sh"
                    "-ec"
                    ''
                      echo "=== routes BEFORE ==="
                      ip route

                      # Remove the VLAN default route so the pod keeps cluster default via eth0
                      ip route del default via 192.168.6.1 dev net1 || true

                      # Optional: make extra-sure cluster CIDRs stay on eth0
                      ip route replace 10.42.0.0/16 via 10.42.0.1 dev eth0 || true
                      ip route replace 10.43.0.0/16 via 10.42.0.1 dev eth0 || true

                      echo "=== routes AFTER ==="
                      ip route
                    ''
                  ];
                }
              ];
              containers = [
                {
                  name = "qbittorrent";
                  image = "${image.imageName}:${image.imageTag}";
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "TZ";
                      value = "America/Los_Angeles";
                    }
                    {
                      name = "PGID";
                      value = toString config.users.groups.nas-media-management.gid;
                    }
                    {
                      name = "UMASK";
                      value = "0002";
                    }
                  ];
                  ports = [ { containerPort = 8080; } ];
                  volumeMounts = [
                    {
                      mountPath = "/config";
                      name = "config";
                    }
                    {
                      mountPath = "/media";
                      name = "media";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "config";
                  persistentVolumeClaim.claimName = "qbittorrent-config-pvc";
                }
                {
                  name = "media";
                  persistentVolumeClaim.claimName = "qbittorrent-media-pvc";
                }
              ];
            };
          };
        };
      };
      qbittorrent-config-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "qbittorrent-config-pvc";
          labels."app.kubernetes.io/name" = "qbittorrent";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          storageClassName = "longhorn";
          resources.requests.storage = "256Mi";
        };
      };
      qbittorrent-media-nfs-pv.content = {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "qbittorrent-media-nfs-pv";
          labels."app.kubernetes.io/name" = "qbittorrent";
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
            path = "/nas_data_primary/media";
          };
        };
      };
      qbittorrent-media-pvc.content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "qbittorrent-media-pvc";
          labels."app.kubernetes.io/name" = "qbittorrent";
        };
        spec = {
          selector.matchLabels."app.kubernetes.io/name" = "qbittorrent";
          accessModes = [ "ReadOnlyMany" ];
          volumeName = "qbittorrent-media-nfs-pv";
          storageClassName = "";
          resources.requests.storage = "1Ti";
        };
      };
      qbittorrent-service.content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "qbittorrent";
          labels."app.kubernetes.io/name" = "qbittorrent";
        };
        spec = {
          selector."app.kubernetes.io/name" = "qbittorrent";
          ports = [
            {
              port = 8080;
              targetPort = 8080;
            }
          ];
        };
      };
      qbittorrent-ingress.content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "qbittorrent";
          labels."app.kubernetes.io/name" = "qbittorrent";
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "web";
            "gethomepage.dev/description" = "Torrenting client";
            "gethomepage.dev/enabled" = "true";
            "gethomepage.dev/group" = "Downloads";
            "gethomepage.dev/icon" = "qbittorrent.png";
            "gethomepage.dev/name" = "QBittorrent";
          };
        };
        spec = {
          ingressClassName = "traefik";
          rules = [
            {
              host = "qbittorrent.internal.perren.cloud";
              http = {
                paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend = {
                      service = {
                        name = "qbittorrent";
                        port.number = 8080;
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
