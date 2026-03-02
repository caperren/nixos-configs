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
let
  wireguardServicesConfig = (import ../../constants/wireguard.nix).services;
in
{
  imports = [
    # Users
    ../../users/apollo-admin/apollo-admin-home-manager.nix

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
    ../kubernetes/apollo-2000/longhorn.nix # Distributed block storage
    ../kubernetes/apollo-2000/multus.nix # VLAN-aware networking

    # Hardware Devices
#    #    ../kubernetes/apollo-2000/device-gpu-nvidia.nix
    ../kubernetes/apollo-2000/device-zigbee.nix
    ../kubernetes/apollo-2000/device-zwave.nix
#
#    # Kubernetes Applications
#    #    ../kubernetes/apollo-2000/autobrr.nix
    ../kubernetes/apollo-2000/diun.nix
    ../kubernetes/apollo-2000/esphome.nix
    ../kubernetes/apollo-2000/gitea.nix
#    #    ../kubernetes/apollo-2000/grafana.nix
    ../kubernetes/apollo-2000/hetzner-ddns.nix
    ../kubernetes/apollo-2000/home-assistant.nix
    ../kubernetes/apollo-2000/homepage.nix
#    #    ../kubernetes/apollo-2000/immich.nix
    ../kubernetes/apollo-2000/jellyfin.nix
    ../kubernetes/apollo-2000/komga.nix
    ../kubernetes/apollo-2000/lubelogger.nix
#    #    ../kubernetes/apollo-2000/node-exporter.nix
#    ../kubernetes/apollo-2000/ollama.nix
    ../kubernetes/apollo-2000/openwebui.nix
    ../kubernetes/apollo-2000/pg-admin.nix
    ../kubernetes/apollo-2000/postgres.nix
#    #    ../kubernetes/apollo-2000/prometheus.nix
#    #    ../kubernetes/apollo-2000/prowlarr.nix
    ../kubernetes/apollo-2000/qbittorrent.nix
#    #    ../kubernetes/apollo-2000/radarr.nix
    ../kubernetes/apollo-2000/rclone.nix
    ../kubernetes/apollo-2000/spliit.nix
    ../kubernetes/apollo-2000/stash.nix
    ../kubernetes/apollo-2000/technitium.nix
    ../kubernetes/apollo-2000/zwave-js-ui.nix
  ];

  time.timeZone = "America/Los_Angeles";
  networking.nameservers = [ "192.168.1.1" ];

  # Shitty bandaid until ollama can natively consider zfs ram caching as actually available, or provide an override flag
  # https://github.com/ollama/ollama/issues/5700
  # Setting to 24 Gibibytes for now
  boot.kernelParams = [ "zfs.zfs_arc_max=25769800000" ];

  sops.secrets = {
    "wireguard/${config.networking.hostName}/private-key".sopsFile = ../../secrets/hetzner.yaml;
    "wireguard/${config.networking.hostName}/preshared-key".sopsFile = ../../secrets/hetzner.yaml;
  };

  boot.zfs.extraPools = [
    "kubernetes_data"
  ];

  systemd = {
    # Set post-boot zfs options that aren't declarative through nixos directly
    services = {
      set-zfs-options = {
        enable = true;
        after = [ "network.target" ];
        wantedBy = [
          "k3s.service"
          "multi-user.target"
        ];
        description = "Sets zfs options post-boot";

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScript "set-zfs-options.sh" ''
            set -e

            while [ ! -d "/kubernetes_data" ]; do
                sleep 1
            done

            if [ ! `zfs list -H -d0 -o name kubernetes_data/longhorn-ext4` ]; then
              zfs create kubernetes_data/longhorn-ext4 -V 350G
              while [ ! -e "/dev/zvol/kubernetes_data/longhorn-ext4" ]; do
                  sleep 1
              done

              mkfs.ext4 /dev/zvol/kubernetes_data/longhorn-ext4

              if [ ! -d "/mnt/longhorn" ]; then
                mkdir -p /mnt/longhorn;
              fi
            fi

            if [ ! `mountpoint -q /mnt/longhorn` ]; then
                mount -o noatime,discard /dev/zvol/kubernetes_data/longhorn-ext4 /mnt/longhorn
            fi
          ''}";

        };

        path = with pkgs; [
          zfs
          coreutils
          e2fsprogs
          util-linux
        ];
      };
      k3s.unitConfig = {
        After = [ "set-zfs-options.service" ];
        Requires = [ "set-zfs-options.service" ];
      };
    };
  };

  # VLANs for use with multus
  networking.vlans.vlan5 = {
    id = 5;
    interface = "eno50";
  };
  networking.interfaces.vlan5.useDHCP = false;

  # Wireguard connection to my vps, for tunnelled reverse-proxying
  networking.wg-quick.interfaces = {
    wg0 = {
      mtu = wireguardServicesConfig.mtu;
      address = [ wireguardServicesConfig.peers.${config.networking.hostName}.address ];
      privateKeyFile = config.sops.secrets."wireguard/${config.networking.hostName}/private-key".path;

      # Known issue with using privateKeyFile where persistentKeepalive below is ignored
      # https://wiki.nixos.org/wiki/WireGuard#Tunnel_does_not_automatically_connect_despite_persistentKeepalive_being_set
      postUp = [ "wg set wg0 peer ${wireguardServicesConfig.peers."cap-hetz-01".publicKey} persistent-keepalive 25" ];

      peers = [
        {
          publicKey = wireguardServicesConfig.peers."cap-hetz-01".publicKey;
          presharedKeyFile = config.sops.secrets."wireguard/${config.networking.hostName}/preshared-key".path;
          allowedIPs = wireguardServicesConfig.allowedIPs;
          endpoint = "${wireguardServicesConfig.host}:${toString wireguardServicesConfig.port}";
          persistentKeepalive = wireguardServicesConfig.persistentKeepalive;
        }
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
