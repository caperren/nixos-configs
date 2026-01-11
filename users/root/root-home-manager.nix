{ config, ... }:
{
  sops.secrets."accounts/root/hashed-password" = {
    sopsFile = ../../secrets/default.yaml;
    neededForUsers = true;
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets."accounts/root/hashed-password".path;
  };
}
