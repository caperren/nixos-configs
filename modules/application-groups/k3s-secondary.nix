{ config, pkgs, ... }:
{
  services.k3s = {
    enable = true;
    role = "server"; # Or "agent" for worker only nodes
    token = "forinitialtestingonly";
    serverAddr = "https://cap-clust-01:6443";
  };
}
