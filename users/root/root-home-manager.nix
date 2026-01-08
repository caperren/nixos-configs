{ config, ... }:
{
  sops.secrets."accounts/root/hashed-password".sopsFile = ../../secrets/default.yaml;

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."accounts/root/hashed-password".path;
  };
}
