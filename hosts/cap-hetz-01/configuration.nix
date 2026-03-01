{ config, pkgs, ... }:
let
  a = "";
in
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/hetzner-admin/hetzner-admin-home-manager.nix

    # System Configuration
    ../../modules/system/fonts.nix
    ../../modules/system/grub.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/security.nix
    ../../modules/system/server.nix
    ../../modules/system/ssd.nix

    # Application Groups
    ../../modules/application-groups/system-utilities.nix

  ];
  sops.secrets = {
    "caddy/Caddyfile" = {
      sopsFile = ../../secrets/hetzner-Caddyfile;
      format = "binary";
#      owner = "caddy";
#      group = "caddy";
      mode = "0440";
    };
  };

  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "cap-hetz-01";

  time.timeZone = "America/Los_Angeles";

  services.caddy = {
    enable = true;
#    configFile = config.sops.secrets."caddy/Caddyfile".path;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
