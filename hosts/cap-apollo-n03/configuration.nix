{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Host Groups
    ../../modules/host-groups/apollo-2000-k3s-cluster.nix
  ];

  networking.hostName = "cap-apollo-n03";
  networking.hostId = "2d7aca8d";
}
