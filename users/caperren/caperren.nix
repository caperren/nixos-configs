{ config, pkgs, ... }:
{
  users.users.caperren = {
    isNormalUser = true;
    description = "Corwin Perren";
    uid = 2000;
  };
}
