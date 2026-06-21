{ pkgs, config, ... }:

{

  nixpkgs.config.rocmSupport = true;
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    #    environmentVariables = {
    #      # For ROCm / HIP:
    #      #      OLLAMA_VULKAN = "0";
    #      #      ROCR_VISIBLE_DEVICES = "GPU-XX";
    #
    #      # For Vulkan instead:
    #      GGML_VK_VISIBLE_DEVICES = "1";
    #
    #      #      OLLAMA_DEBUG = "1";
    #    };
    loadModels = [
      #      "llama3.2:3b"
      #      "phi4-reasoning:14b"
      #      "dolphin3:8b"
      #      "smallthinker:3b"
      #      "gemma3:4b"
      "gemma4:12b"
      #      "gemma3:27b"
      "deepcoder:14b"
      "qwen3.5:9b"
      #      "qwen3.6:27b"
      #      "nomic-embed-text"
    ];
    syncModels = true;
  };

  services.open-webui = {
    enable = true;
    port = 8888;
  };

  #  environment.systemPackages = with pkgs; [
  #    oterm
  #    alpaca
  #    aichat
  #    fabric-ai
  #    aider-chat
  #
  #    # tgpt
  #    # smartcat
  #    # nextjs-ollama-llm-ui
  #    # open-webui
  #  ];
}
