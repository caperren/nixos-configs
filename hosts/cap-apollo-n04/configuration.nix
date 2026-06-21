{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # System Configuration
    ../../modules/system/gpu-nvidia.nix

    # Host Groups
    ../../modules/host-groups/apollo-2000-k3s-cluster.nix

    # Application Groups
    ../../modules/application-groups/ai.nix
  ];

  networking.hostName = "cap-apollo-n04";
  networking.hostId = "32d76617";

  services.ollama = {
    package = pkgs.ollama-cuda;
    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0"; # or "1" for the other NVIDIA GPU
    };
  };

  services.open-webui = {
    host = "0.0.0.0";
  };
}
