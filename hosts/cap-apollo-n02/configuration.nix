{ config, pkgs, ... }:
let
  wgPublicKey = "EiFCVUvibomC8du68TGYvWYi/haNv0MELPJvnhPAcHA=";
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
}
