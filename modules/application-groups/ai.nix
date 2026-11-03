{ pkgs, config, ... }:

{

  nixpkgs.config.rocmSupport = true;
  services.ollama = {
    enable = true;

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
