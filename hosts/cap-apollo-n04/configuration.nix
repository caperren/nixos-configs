{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # System Configuration
    ../../modules/system/gpu-nvidia.nix

    # Host Groups
    ../../modules/host-groups/apollo-2000-k3s-cluster.nix
  ];

  networking.hostName = "cap-apollo-n04";
  networking.hostId = "32d76617";
}
