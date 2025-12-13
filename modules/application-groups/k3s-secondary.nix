{ config, pkgs, ... }:
{
  sops.secrets.k3s_token.sopsFile = ../../secrets/cluster.yaml;

  services.k3s = {
    enable = false;
    role = "server"; # Or "agent" for worker only nodes
    tokenFile = config.sops.secrets.k3s_token.path;
    serverAddr = "https://cap-clust-01:6443";
  };
}
