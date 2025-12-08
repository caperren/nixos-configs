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

  networking.hostName = "cap-clust-03";
}
