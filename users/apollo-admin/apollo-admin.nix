{ config, pkgs, ... }:
{
  users.users.apollo-admin = {
    isNormalUser = true;
    description = "Cluster Admin";
    uid = 2001;
  };
}
