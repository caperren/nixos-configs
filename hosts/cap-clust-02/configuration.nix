{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Host Groups
    ../../modules/host-groups/cluster.nix

  ];

  networking.hostName = "cap-clust-02";
}
