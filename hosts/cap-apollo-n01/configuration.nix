{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Host Groups
    ../../modules/host-groups/apollo-2000.nix
  ];

  networking.hostName = "cap-apollo-n01";

}
