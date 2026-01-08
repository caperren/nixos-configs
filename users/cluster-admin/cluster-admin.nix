{ config, pkgs, ... }:
{
  users.users.cluster-admin = {
    isNormalUser = true;
    description = "Cluster Admin";
    uid = 202;
  };
}
