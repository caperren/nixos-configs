{ config, pkgs, ... }:
let
  sshCaperrenDesktopPubkey = builtins.readFile ../caperren/pubkeys/cap-nr200p.pub;
  sshCaperrenLaptopPubkey = builtins.readFile ../caperren/pubkeys/cap-slim7.pub;
in
{
  sops.secrets."accounts/apollo-admin/hashed-password".sopsFile = ../../secrets/apollo-2000.yaml;

  users.users.apollo-admin = {
    isNormalUser = true;
    description = "Apollo Admin";
    hashedPasswordFile = config.sops.secrets."accounts/apollo-admin/hashed-password".path;
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      sshCaperrenDesktopPubkey
      sshCaperrenLaptopPubkey
    ];
  };

  home-manager.users.apollo-admin = {
    home.username = "apollo-admin";
    home.homeDirectory = "/home/apollo-admin";
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
