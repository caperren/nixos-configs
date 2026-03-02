# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:
let
  wireguardServicesConfig = (import ../../constants/wireguard.nix).services;
in
{

  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/caperren/caperren-home-manager.nix

    # System Configuration
    ../../modules/system/cpu-amd.nix
    ../../modules/system/displaylink.nix
    ../../modules/system/fonts.nix
    ../../modules/system/gpu-amd.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/homelab-nfs-mounts.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/laptop.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/pipewire.nix
    ../../modules/system/security.nix
    ../../modules/system/ssd.nix
    ../../modules/system/systemd-boot.nix

    # Application Groups
    ../../modules/application-groups/3d-design.nix
    ../../modules/application-groups/android.nix
    ../../modules/application-groups/downloads.nix
    ../../modules/application-groups/gaming.nix
    ../../modules/application-groups/hobby-rc.nix
    ../../modules/application-groups/homelab.nix
    ../../modules/application-groups/media.nix
    ../../modules/application-groups/media-creation.nix
    ../../modules/application-groups/pcb-design.nix
    ../../modules/application-groups/productivity.nix
    ../../modules/application-groups/programming.nix
    ../../modules/application-groups/radio.nix
    ../../modules/application-groups/social.nix
    ../../modules/application-groups/system-utilities.nix
    ../../modules/application-groups/virtualization.nix
    ../../modules/application-groups/web.nix
  ];

  sops.secrets = {
    "wireguard/${config.networking.hostName}/private-key".sopsFile = ../../secrets/hetzner.yaml;
    "wireguard/${config.networking.hostName}/preshared-key".sopsFile = ../../secrets/hetzner.yaml;
  };

  networking.hostName = "cap-slim7";
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

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  # time.timeZone = "Pacific/Honolulu";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
