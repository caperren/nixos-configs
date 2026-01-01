{ config, pkgs, ... }:
let
  # Match "cap-apollo-n02" → [ "cap-apollo" "02" ]
  match = builtins.match "^(.*)-n([0-9]+)$" config.networking.hostName;

  iloHost =
    if match == null then
      throw "Unexpected hostname format: ${config.networking.hostName}"
    else
      "${builtins.elemAt match 0}-ilo${builtins.elemAt match 1}";

  isK3sPrimary = builtins.elemAt match 1 == "02";
in
{
  imports = [
    # Users
    ../../users/apollo-admin/apollo-admin.nix

    # System Configuration
    ../../modules/system/cpu-intel.nix
    ../../modules/system/fonts.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/hpe-ilo-fans.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/security.nix
    ../../modules/system/systemd-boot.nix

    # Application Groups
    ../../modules/application-groups/system-utilities-cluster.nix
    ../../modules/application-groups/virtualization.nix
  ];

  time.timeZone = "America/Los_Angeles";



  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s_token.path;
    clusterInit = isK3sPrimary;
    serverAddr = if isK3sPrimary then "" else "https://cap-apollo-n02:6443";
  };



  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
