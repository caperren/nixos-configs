{
  config,
  pkgs,
  lib,
  ...
}:
let
  gpuHavingNodeName = "cap-apollo-n04";
in
{
  services.k3s = {
    containerdConfigTemplate = ''
      {{ template "base" . }}

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
        privileged_without_host_devices = false
        runtime_engine = ""
        runtime_root = ""
        runtime_type = "io.containerd.runc.v2"

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
        BinaryName = "${pkgs.nvidia-container-toolkit.tools}/bin/nvidia-container-runtime.cdi"
    '';
    manifests = lib.mkIf (config.networking.hostName == "cap-apollo-n02") {
      nvidia-runtime-class.content = {
        apiVersion = "node.k8s.io/v1";
        kind = "RuntimeClass";
        handler = "nvidia";
        metadata = {
          labels."app.kubernetes.io/component" = "gpu-operator";
          name = "nvidia";
        };
      };
    };
  };
}
