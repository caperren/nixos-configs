{ config, pkgs, ... }:
{
  imports = [
    ./apollo-admin/apollo-admin.nix
    ./caperren/caperren.nix
    ./cluster-admin/cluster-admin.nix
    ./crestline/crestline.nix
  ];
}
