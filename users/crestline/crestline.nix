{ config, pkgs, ... }:
{
  users.users.crestline = {
    isNormalUser = true;
    description = "Crestline";
    uid = 2003;
  };
}
