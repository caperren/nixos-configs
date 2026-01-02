{ config, pkgs, ... }:
let
  k3s_primaries = [ "cap-apollo-n02" "cap-clust-01"];

  # Match "cap-apollo-n02" → [ "cap-apollo" "02" ]
  match = builtins.match "^(.*)-n([0-9]+)$" config.networking.hostName;

  isK3sPrimary = lib.lists.elem config.networking.hostName k3s_primaries;
in
{
  sops.secrets.k3s_token.sopsFile = ../../secrets/apollo-2000.yaml;

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s_token.path;
    clusterInit = isK3sPrimary;
    serverAddr = if isK3sPrimary then "" else "https://cap-apollo-n02:6443";
  };
}
