{ config, pkgs, ... }:
{
  sops.secrets.k3s_token.sopsFile = /etc/nixos/secrets/cluster.yaml;

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s_token.path;
    clusterInit = true;
  };
}
