{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Host Groups
    ../../modules/host-groups/apollo-2000-k3s-cluster.nix

    # Application Groups
    ../../modules/application-groups/ai.nix
  ];

  networking.hostName = "cap-apollo-n04";
  networking.hostId = "32d76617";

  services.open-webui = {
    host = "0.0.0.0";
  };
}
