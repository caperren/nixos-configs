{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf (config.networking.hostName == "cap-apollo-n02") {

  services.k3s = {
    manifests = {
      multus-helmchart.content = {
        apiVersion = "helm.cattle.io/v1";
        kind = "HelmChart";
        metadata = {
          name = "multus";
          namespace = "kube-system";
        };
        spec = {
          repo = "https://rke2-charts.rancher.io";
          chart = "rke2-multus";
          targetNamespace = "kube-system";

          version = "v4.2.312";

          valuesContent = ''
            config:
              fullnameOverride: multus
              cni_conf:
                confDir: /var/lib/rancher/k3s/agent/etc/cni/net.d
                binDir: /var/lib/rancher/k3s/data/cni/
                kubeconfig: /var/lib/rancher/k3s/agent/etc/cni/net.d/multus.d/multus.kubeconfig
                multusAutoconfigDir: /var/lib/rancher/k3s/agent/etc/cni/net.d
            manifests:
              dhcpDaemonSet: true
          '';
        };
      };
    };
  };
}
