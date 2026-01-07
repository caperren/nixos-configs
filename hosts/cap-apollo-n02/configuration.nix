{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Host Groups
    ../../modules/host-groups/apollo-2000-k3s-cluster.nix
  ];

  networking.hostName = "cap-apollo-n02";
  networking.hostId = "bc7334b5";

  sops.secrets = {
  "cap-apollo-n02/wireguard/private-key".sopsFile = ../../secrets/apollo-2000.yaml;
  "cap-apollo-n02/wireguard/preshared-key".sopsFile = ../../secrets/apollo-2000.yaml;
  };

  # Wireguard connection to my vps, for tunnelled reverse-proxying
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.8.0.4/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."cap-apollo-n02/wireguard/private-key".path;

      peers = [
        {
          publicKey = "EiFCVUvibomC8du68TGYvWYi/haNv0MELPJvnhPAcHA=";
          presharedKeyFile = config.sops.secrets."cap-apollo-n02/wireguard/preshared-key".path;
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "caperren.com:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
