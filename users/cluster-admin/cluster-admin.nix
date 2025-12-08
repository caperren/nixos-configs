{ config, pkgs, ... }:
{
  users.users.cluster-admin = {
    initialPassword = "changeme";
    isNormalUser = true;
    description = "Cluster Admin";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  home-manager.users.cluster-admin = {
    home.username = "cluster-admin";
    home.homeDirectory = "/home/cluster-admin";
    home.stateVersion = "25.05";

    home.packages = with pkgs; [ ];

    programs.bash.enable = true;

    programs.git = {
      enable = true;
      settings.user = {
        name = "Corwin Perren";
        email = "caperren@gmail.com";
      };

    };

    programs.kitty = {
      enable = true;
      font.name = "JetBrains Mono";
    };
  };
}
