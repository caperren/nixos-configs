{ config, pkgs, ... }:
let wgPublicKey = "EiFCVUvibomC8du68TGYvWYi/haNv0MELPJvnhPAcHA=";
in
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
#  networking.wg-quick.interfaces = {
#    wg0 = {
#      mtu = 1420;
#      address = [ "10.8.0.4/24" ];
#      listenPort = 51820;
#      privateKeyFile = config.sops.secrets."cap-apollo-n02/wireguard/private-key".path;
#
#      peers = [
#        {
#          publicKey = wgPublicKey;
#          presharedKeyFile = config.sops.secrets."cap-apollo-n02/wireguard/preshared-key".path;
#          allowedIPs = [ "10.8.0.0/24" ];
#          endpoint = "caperren.com:51820";
#        }
#      ];
#    };
#  };
}
