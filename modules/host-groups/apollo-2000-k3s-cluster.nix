# Find disks with `ls -l /dev/disk/by-id/`
# Ensure you're not nuking your boot drive with `lsblk -o NAME,SIZE,MODEL,SERIAL,UUID`
# To create the kubernetes_data zfs pool, use the following example template
# sudo wipefs -a /dev/disk/by-id/ata-VK000240GWSRQ_S44HNA0M806711 && \
# sudo wipefs -a /dev/disk/by-id/ata-VK000240GWSRQ_S44HNE0M306863 && \
# sudo wipefs -a /dev/disk/by-id/ata-VK000240GWSRQ_S44HNA0M807518 && \
# sudo zpool labelclear -f /dev/disk/by-id/ata-VK000240GWSRQ_S44HNA0M806711 ; \
# sudo zpool labelclear -f /dev/disk/by-id/ata-VK000240GWSRQ_S44HNE0M306863 ; \
# sudo zpool labelclear -f /dev/disk/by-id/ata-VK000240GWSRQ_S44HNA0M807518 ; \
# sudo zpool create \
#   -o ashift=12 \
#   kubernetes_data \
#   raidz1 \
#   /dev/disk/by-id/ata-VK000240GWSRQ_S44HNA0M806711 \
#   /dev/disk/by-id/ata-VK000240GWSRQ_S44HNE0M306863 \
#   /dev/disk/by-id/ata-VK000240GWSRQ_S44HNA0M807518 && \
# sudo zfs set compression=lz4 kubernetes_data && \
# sudo zfs set atime=off kubernetes_data && \
# sudo zfs set xattr=sa kubernetes_data && \
# sudo zpool set autotrim=on kubernetes_data && \
# sudo zpool scrub kubernetes_data && \
# sudo zpool status

{ config, pkgs, ... }:
{
  imports = [
    # Users
    ../../users/apollo-admin/apollo-admin.nix

    # System Configuration
    ../system/cpu-intel.nix
    ../system/fonts.nix
    ../system/home-manager-settings.nix
    ../system/hpe-ilo-fans.nix
    ../system/internationalization.nix
    ../system/networking.nix
    ../system/nix-settings.nix
    ../system/security.nix
    ../system/server.nix
    ../system/ssd.nix
    ../system/systemd-boot.nix
    ../system/zfs.nix

    # Application Groups
    ../application-groups/k3s.nix
    ../application-groups/system-utilities-cluster.nix
    ../application-groups/virtualization.nix

    # Core Kubernetes Applications
    ../kubernetes/apollo-2000/longhorn.nix

    # Kubernetes Applications
    ../kubernetes/apollo-2000/autobrr.nix
    ../kubernetes/apollo-2000/esphome.nix
    ../kubernetes/apollo-2000/secrets.nix
    ../kubernetes/apollo-2000/gitea.nix
    ../kubernetes/apollo-2000/grafana.nix
    #    ../kubernetes/apollo-2000/helm-hello-world.nix
    ../kubernetes/apollo-2000/hetzner-ddns.nix
    ../kubernetes/apollo-2000/home-assistant.nix
    ../kubernetes/apollo-2000/immich.nix
    ../kubernetes/apollo-2000/kavita.nix
    ../kubernetes/apollo-2000/node-exporter.nix
    ../kubernetes/apollo-2000/plex.nix
    ../kubernetes/apollo-2000/prometheus.nix
    ../kubernetes/apollo-2000/prowlarr.nix
    ../kubernetes/apollo-2000/radarr.nix
    ../kubernetes/apollo-2000/rclone.nix
    ../kubernetes/apollo-2000/spliit.nix
    ../kubernetes/apollo-2000/stash.nix
    ../kubernetes/apollo-2000/technitium.nix
    ../kubernetes/apollo-2000/yt-dlp-web-ui.nix
    ../kubernetes/apollo-2000/zwave-js-ui.nix
  ];

  time.timeZone = "America/Los_Angeles";

  boot.zfs.extraPools = [
    "kubernetes_data"
  ];

  # Set post-boot zfs options that aren't declarative through nixos directly
  systemd = {
    services.set-zfs-options = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "Sets zfs options post-boot";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "set-zfs-options.sh" ''
          set -e

          if [ ! `zfs list -H -d0 -o name kubernetes_data/longhorn-ext4` ]; then
            zfs create kubernetes_data/longhorn-ext4 -V 350G
            while [ ! -e "/dev/zvol/kubernetes_data/longhorn-ext4" ]; do
                sleep 1;
            done
            mkfs.ext4 /dev/zvol/kubernetes_data/longhorn-ext4
            mkdir -p /mnt
          fi
        ''}";

      };

      path = with pkgs; [
        zfs
        coreutils
        e2fsprogs
      ];
    };
    mounts = [
      {
        what = "/dev/zvol/kubernetes_data/longhorn-ext4";
        type = "ext4";
        where = "/mnt/longhorn";
        options = "noatime,discard";
      }
    ];
    automounts = [
        {
        where = "/mnt/longhorn";
        after = [ "set-zfs-options.service" ];
      }
    ];

  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
