{ config, pkgs, ... }:
let
  wireguardServicesConfig = (import ../../constants/wireguard.nix).services;
in
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/hetzner-admin/hetzner-admin-home-manager.nix

    # System Configuration
    ../../modules/system/fonts.nix
    ../../modules/system/grub.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/security.nix
    ../../modules/system/server.nix
    ../../modules/system/ssd.nix

    # Application Groups
    ../../modules/application-groups/system-utilities.nix

  ];

  users.users.caddy.enable = true;
  sops.secrets = {
    "wireguard/${config.networking.hostName}/private-key".sopsFile = ../../secrets/hetzner.yaml;
    "wireguard/cap-slim7/preshared-key".sopsFile = ../../secrets/hetzner.yaml;
    "wireguard/cap-nr200p/preshared-key".sopsFile = ../../secrets/hetzner.yaml;
    "wireguard/cap-apollo-n02/preshared-key".sopsFile = ../../secrets/hetzner.yaml;
    "wireguard/cap-apollo-n03/preshared-key".sopsFile = ../../secrets/hetzner.yaml;
    "wireguard/cap-apollo-n04/preshared-key".sopsFile = ../../secrets/hetzner.yaml;
    "wireguard/cap-joyride-01/preshared-key".sopsFile = ../../secrets/hetzner.yaml;

    "caddy/Caddyfile" = {
      sopsFile = ../../secrets/hetzner-Caddyfile;
      format = "binary";
      owner = "caddy";
      group = "caddy";
      mode = "0440";

      restartUnits = [ "caddy.service" ];
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.grub.device = "/dev/sda";

  networking = {
    hostName = "cap-hetz-01";

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];

    interfaces.enp1s0 = {
      ipv4.addresses = [
        {
          address = "5.78.42.43";
          prefixLength = 32;
        }
      ];
      ipv6.addresses = [
        {
          address = "2a01:4ff:1f0:8878::1";
          prefixLength = 64;
        }
      ];
    };
    defaultGateway = {
      address = "172.31.1.1";
      interface = "enp1s0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };

    enableIPv6 = true;

    wireguard = {
      enable = true;
      interfaces.services = {
        privateKeyFile = config.sops.secrets."wireguard/${config.networking.hostName}/private-key".path;
        ips = [ "${wireguardServicesConfig.peers.${config.networking.hostName}.address}/24" ];
        listenPort = wireguardServicesConfig.port;
        mtu = wireguardServicesConfig.mtu;

        peers = [
          {
            publicKey = wireguardServicesConfig.peers."cap-slim7".publicKey;
            allowedIPs = [ "${wireguardServicesConfig.peers."cap-slim7".address}/32" ];
            presharedKeyFile = config.sops.secrets."wireguard/cap-slim7/preshared-key".path;
          }
          {
            publicKey = wireguardServicesConfig.peers."cap-nr200p".publicKey;
            allowedIPs = [ "${wireguardServicesConfig.peers."cap-nr200p".address}/32" ];
            presharedKeyFile = config.sops.secrets."wireguard/cap-nr200p/preshared-key".path;
          }
          {
            publicKey = wireguardServicesConfig.peers."cap-apollo-n02".publicKey;
            allowedIPs = [ "${wireguardServicesConfig.peers."cap-apollo-n02".address}/32" ];
            presharedKeyFile = config.sops.secrets."wireguard/cap-apollo-n02/preshared-key".path;
          }
          {
            publicKey = wireguardServicesConfig.peers."cap-apollo-n03".publicKey;
            allowedIPs = [ "${wireguardServicesConfig.peers."cap-apollo-n03".address}/32" ];
            presharedKeyFile = config.sops.secrets."wireguard/cap-apollo-n03/preshared-key".path;
          }
          {
            publicKey = wireguardServicesConfig.peers."cap-apollo-n04".publicKey;
            allowedIPs = [ "${wireguardServicesConfig.peers."cap-apollo-n04".address}/32" ];
            presharedKeyFile = config.sops.secrets."wireguard/cap-apollo-n04/preshared-key".path;
          }
          {
            publicKey = wireguardServicesConfig.peers."cap-joyride-01".publicKey;
            allowedIPs = [ "${wireguardServicesConfig.peers."cap-joyride-01".address}/32" ];
            presharedKeyFile = config.sops.secrets."wireguard/cap-joyride-01/preshared-key".path;
          }
        ];
      };
    };
  };

  time.timeZone = "America/Los_Angeles";

  services.caddy = {
    enable = true;
    configFile = config.sops.secrets."caddy/Caddyfile".path;
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      searxng-core = {
        image = "ghcr.io/searxng/searxng:latest";
        autoStart = true;

        ports = [
          "8080:8080"
        ];

        environment = {
          SEARXNG_VALKEY_URL = "valkey://172.17.0.1:6379";
        };

        volumes = [
          "/oci/searxng/config/:/etc/searxng/:Z"
          "core-data:/var/cache/searxng/"
          "/etc/localtime:/etc/localtime:ro"
        ];

        #        extraOptions = [
        #          "--network=host"
        #        ];
      };
      searxng-valkey = {
        image = "docker.io/valkey/valkey:9-alpine";
        autoStart = true;

        cmd = [
          "valkey-server"
          "--save"
          "30"
          "1"
          "--loglevel"
          "warning"
        ];

        ports = [
          "6379:6379"
        ];

        volumes = [
          "valkey-data:/data/"
        ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
