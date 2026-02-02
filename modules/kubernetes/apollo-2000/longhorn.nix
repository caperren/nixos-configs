{
  config,
  pkgs,
  lib,
  ...
}:
let
  # If you have 3 k3s nodes and want HA volumes, 2 is a common homelab default.
  # If you want maximum resilience (and can afford space), set 3.
  defaultReplicaCount = 2;
in
{
  # Required by longhorn
  services.openiscsi = {
    enable = true;
    name = "iqn.2026-01.local.k3s:${config.networking.hostName}";
  };
  environment.systemPackages = with pkgs; [
    openiscsi
    nfs-utils
  ];

  systemd = {
    # Fix for failed environment check on openiscsi
    # https://github.com/longhorn/longhorn/issues/2166#issuecomment-3315367546
    services.iscsid.serviceConfig = {
      PrivateMounts = "yes";
      BindPaths = "/run/current-system/sw/bin:/bin";
    };

    # and one from the same thread for a failed nsenter with longhorn rwx
    # https://github.com/longhorn/longhorn/issues/2166#issuecomment-3094699127
    tmpfiles.rules = [
      "L /usr/bin/mount - - - - /run/current-system/sw/bin/mount"
    ];
  };

  services.k3s = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
    manifests = {
      longhorn-namespace.content = {
        apiVersion = "v1";
        kind = "Namespace";
        metadata = {
          name = "longhorn-system";
        };
      };
      longhorn-helmchart.content = {
        apiVersion = "helm.cattle.io/v1";
        kind = "HelmChart";
        metadata = {
          name = "longhorn";
          namespace = "kube-system";
        };
        spec = {
          repo = "https://charts.longhorn.io";
          chart = "longhorn";
          targetNamespace = "longhorn-system";

          # Strongly recommended: pin a version so upgrades are intentional.
          # Replace with the version you want (example only).
          version = "v1.10.1";

          valuesContent = ''
            # Make Longhorn create/mark its StorageClass as the default
            storageClass:
              defaultClass: true

            defaultSettings:
              defaultReplicaCount: ${toString defaultReplicaCount}

              # Where Longhorn stores data on each node:
              defaultDataPath: /mnt/longhorn

              # Make sure we don't overuse the data mount
              storageOverProvisioningPercentage: 100
              storageMinimalAvailablePercentage: 10

              # Optional: if you want node failure to more aggressively evict/recover:
              # nodeDownPodDeletionPolicy: delete-both-statefulset-and-deployment-pod

            # Optional: if you want the UI reachable via Ingress later, you can configure it here
            ingress:
              enabled: true
              host: longhorn.internal.perren.cloud
              annotations:
                gethomepage.dev/description: Distributed block storage filesystem
                gethomepage.dev/enabled: true
                gethomepage.dev/group: Cluster Management
                gethomepage.dev/icon: longhorn.png
                gethomepage.dev/name: Longhorn
                gethomepage.dev/pod-selector: app.kubernetes.io/name=longhorn
          '';
        };
      };
      longhorn-default-backup-target.content = {
        apiVersion = "longhorn.io/v1beta2";
        kind = "BackupTarget";
        metadata = {
          name = "default";
          namespace = "longhorn-system";
        };
        spec = {
          backupTargetURL = "";
          pollInterval = "5m0s";
        };
      };
      longhorn-backup-target-1.content = {
        apiVersion = "longhorn.io/v1beta2";
        kind = "BackupTarget";
        metadata = {
          name = "default";
          namespace = "longhorn-system";
        };
        spec = {
          backupTargetURL = "nfs://192.168.1.41:/nas_data_primary/longhorn?nfsOptions=nfsvers=4.2,retrans=3,actimeo=1";
          pollInterval = "5m0s";
        };
      };
    };
  };
}
