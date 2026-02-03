{ config, pkgs, ... }:
let
  notifyHelpers = import ../../modules/scripts/notify-helpers.nix { inherit pkgs; };
in
{
  sops = {
    secrets = {
      "accounts/root/hashed-password" = {
        sopsFile = ../../secrets/default.yaml;
        neededForUsers = true;
      };

      "bots/perrencloudbot/api-token".sopsFile = ../../secrets/default.yaml;
      "bots/perrencloudbot/chat-ids".sopsFile = ../../secrets/default.yaml;
    };

    templates.notify-provider-config = {
      content = builtins.toJSON {
        telegram = [
          {
            id = "perrencloud";
            telegram_api_key = config.sops.placeholder."bots/perrencloudbot/api-token";
            telegram_chat_id = config.sops.placeholder."bots/perrencloudbot/chat-ids";
            telegram_format = "{{data}}";
            telegram_parsemode = "MarkdownV2";
          }
        ];
      };
      path = "/root/.config/notify/provider-config.yaml";
    };
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."accounts/root/hashed-password".path;
  };

  home-manager.users.root = {
    home.username = "root";
    home.homeDirectory = "/root";
    home.stateVersion = "25.05";

    home.packages = with pkgs; [
      notify
      python314
      notifyHelpers.tgEscape
    ];
  };
}
