{ config, pkgs, lib, ... }:
let
  k3sTokenSopsFile = {
    "cap-apollo-n02" = ../../secrets/apollo-2000.yaml;
    "cap-apollo-n03" = ../../secrets/apollo-2000.yaml;
    "cap-apollo-n04" = ../../secrets/apollo-2000.yaml;
    "cap-clust-01" = ../../secrets/cluster.yaml;
    "cap-clust-02" = ../../secrets/cluster.yaml;
    "cap-clust-03" = ../../secrets/cluster.yaml;
  };
  k3sNodeToPrimary = {
    "cap-apollo-n03" = "cap-apollo-n02";
    "cap-apollo-n04" = "cap-apollo-n02";
    "cap-clust-02" = "cap-clust-01";
    "cap-clust-03" = "cap-clust-01";
  };

  isK3sPrimary = lib.lists.elem "${config.networking.hostName}" (
    lib.unique (lib.attrValues k3sNodeToPrimary)
  );
  serverAddr = if isK3sPrimary then "" else k3sNodeToPrimary.${config.networking.hostName};
in
{
  sops.secrets.k3s_token.sopsFile = k3sTokenSopsFile.${config.networking.hostName};

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s_token.path;
    clusterInit = isK3sPrimary;
    serverAddr = serverAddr;
  };
}
