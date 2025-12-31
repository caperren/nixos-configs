{ config, pkgs, ... }:
{
  sops.secrets = {
    "ssh/ilouser/id_rsa" = {
      sopsFile = ../../secrets/default.yaml;
      path = "/root/.ssh/ilo_id_rsa";
    };
    "ssh/ilouser/id_rsa_pub" = {
      sopsFile = ../../secrets/default.yaml;
      path = "/root/.ssh/ilo_id_rsa.pub";
    };
  };
}
