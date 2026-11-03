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

  hardware.graphics = {
    enable = true;
  };

  services.ollama = {
    package = pkgs.ollama-cuda;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32768";

      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_KEEP_ALIVE = "10m";

      CUDA_VISIBLE_DEVICES = "0"; # or "1" for the other NVIDIA GPU
    };
    #    loadModels = [
    #      #      "llama3.2:3b"
    #      #      "phi4-reasoning:14b"
    #      #      "dolphin3:8b"
    #      #      "smallthinker:3b"
    #      #      "gemma3:4b"
    #      "gemma4:26b"
    #      #      "gemma3:27b"
    #      "deepcoder:14b"
    #      "qwen3.6:27b"
    #      #      "qwen3.6:27b"
    #      #      "nomic-embed-text"
    #    ];
    loadModels = [
      "qwen3:8b"
      "qwen3:14b"
      "qwen2.5-coder:1.5b"
      "qwen2.5-coder:7b"
      "qwen2.5-coder:14b"
      "devstral-small-2"
      "qwen3-embedding:4b"
      "qwen3-vl:8b"
    ];
  };

  services.open-webui = {
    host = "0.0.0.0";
  };
}
