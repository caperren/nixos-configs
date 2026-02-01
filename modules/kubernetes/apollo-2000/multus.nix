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

      # Networks
      vlan-5-nad.content = {
        apiVersion = "k8s.cni.cncf.io/v1";
        kind = "NetworkAttachmentDefinition";
        metadata = {
          name = "vlan5";
          namespace = "default";
        };
        spec.config = builtins.toJSON {
          cniVersion = "0.3.1";
          type = "macvlan";
          master = "vlan5";  # Same on all apollo systems
          mode = "bridge";
          vlan = 5;

          # pick ONE ipam strategy:
          ipam.type = "dhcp";

          # Reference in case I need static ips later
          # ipam = {
          #   type = "host-local";
          #   subnet = "192.168.20.0/24";
          #   rangeStart = "192.168.20.200";
          #   rangeEnd = "192.168.20.250";
          #   gateway = "192.168.20.1";
          #   routes = [{ dst = "0.0.0.0/0"; }];
          # };
        };
      };
    };
  };
}
