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
  hardware = lib.mkIf (config.networking.hostName == gpuHavingNodeName) {
    # Enable modesetting for Wayland compositors (hyprland)
    modesetting.enable = true;
    # Use the open source version of the kernel module (for driver 515.43.04+)
    # Actually, just overridden to false for now
    open = false;
    # Enable the Nvidia settings menu
    nvidiaSettings = true;
    # Select the appropriate driver version for your specific GPU
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Stuff for kube interations
    nvidia-container-toolkit.enable = true;
    nvidia.datacenter.enable = true;
  };
  nixpkgs.config.nvidia.acceptLicense = true;
  virtualisation.containerd = {
    enable = true;
    settings = {
      plugins."io.containerd.grpc.v1.cri" = {
        enable_cdi = true;
        cdi_spec_dirs = [ "/var/run/cdi" ];
      };
    };
  };

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
      nvidia-gpu-node-labeler.content = {
        apiVersion = "v1";
        kind = "Node";
        metadata = {
          name = gpuHavingNodeName;
          labels."nixos-nvidia-cdi" = "gpu-enabled";

        };
      };
      nvidia-runtime-class.content = {
        apiVersion = "node.k8s.io/v1";
        kind = "RuntimeClass";
        handler = "nvidia";
        metadata = {
          name = "nvidia";
          labels."app.kubernetes.io/component" = "gpu-operator";
        };
      };
      generic-cdi-namespace.content = {
        apiVersion = "v1";
        kind = "Namespace";
        metadata.name = "generic-cdi-plugin";
      };
      generic-cdi-plugin-daemonset.content = {
        apiVersion = "apps/v1";
        kind = "DaemonSet";
        metadata = {
          name = "generic-cdi-plugin-daemonset";
          namespace = "generic-cdi-plugin";
        };
        spec = {
          selector.matchLabels.name = "generic-cdi-plugin";
          template = {
            metadata.labels = {
              name = "generic-cdi-plugin";
              "app.kubernetes.io/component" = "generic-cdi-plugin";
              "app.kubernetes.io/name" = "generic-cdi-plugin";
            };
          };

          spec = {
            containers = [
              {
                image = "ghcr.io/olfillasodikno/generic-cdi-plugin:main";
                name = "generic-cdi-plugin";
                command = [
                  "/generic-cdi-plugin"
                  "/var/run/cdi/nvidia-container-toolkit.json"
                ];
                imagePullPolicy = "Always";
                securityContext.privileged = true;
                tty = true;
                volumeMounts = [
                  {
                    name = "kubelet";
                    mountPath = "/var/lib/kubelet";
                  }
                  {
                    name = "nvidia-container-toolkit";
                    mountPath = "/var/run/cdi/nvidia-container-toolkit.json";
                  }
                ];
              }
            ];

            volumes = [
              {
                name = "kubelet";
                hostPath = {
                  path = "/var/lib/kubelet";
                };
              }
              {
                name = "nvidia-container-toolkit";
                hostPath = {
                  path = "/var/run/cdi/nvidia-container-toolkit.json";
                };
              }
            ];

            affinity = {
              nodeAffinity = {
                requiredDuringSchedulingIgnoredDuringExecution = {
                  nodeSelectorTerms = [
                    {
                      matchExpressions = [
                        {
                          key = "nixos-nvidia-cdi";
                          operator = "In";
                          values = [ "enabled" ];
                        }
                      ];
                    }
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
