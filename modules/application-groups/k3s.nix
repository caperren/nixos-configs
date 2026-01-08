{
  config,
  pkgs,
  lib,
  ...
}:
let
  k3sTokenSopsFile = {
    "cap-apollo-n02" = ../../secrets/apollo-2000.yaml;
    "cap-apollo-n03" = ../../secrets/apollo-2000.yaml;
    "cap-apollo-n04" = ../../secrets/apollo-2000.yaml;
    "cap-clust-01" = ../../secrets/cluster.yaml;
    "cap-clust-02" = ../../secrets/cluster.yaml;
    "cap-clust-03" = ../../secrets/cluster.yaml;
  };
  k3sPrimaries = [
    "cap-apollo-n02"
    "cap-clust-n01"
  ];
  k3sNodeToPrimary = {
    "cap-apollo-n03" = "https://cap-apollo-n02:6443";
    "cap-apollo-n04" = "https://cap-apollo-n02:6443";
    "cap-clust-02" = "https://cap-clust-01:6443";
    "cap-clust-03" = "https://cap-clust-01:6443";
  };

  isK3sPrimary = lib.lists.elem "${config.networking.hostName}" k3sPrimaries;
  serverAddr = if isK3sPrimary then "" else k3sNodeToPrimary.${config.networking.hostName};
in
{
  sops.secrets.k3s_token.sopsFile = k3sTokenSopsFile.${config.networking.hostName};

  environment.etc = {
    # Enable the embedded registry mirror for all registries
    "rancher/k3s/registries.yaml".text = ''
      mirrors:
        "*":
    '';
  };

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s_token.path;
    clusterInit = isK3sPrimary;
    serverAddr = serverAddr;
    extraFlags = [
      "--embedded-registry"
    ];
  };
}
