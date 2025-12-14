{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Host Groups
    ../../modules/host-groups/cluster.nix

    # Application Groups
    ../../modules/application-groups/k3s-primary.nix
  ];

#  sops.secrets.k3s_token.sopsFile = ../../secrets/cluster.yaml;

  networking.hostName = "cap-clust-01";
}
