# Edit this configuration file to define what should be installed on your system.
# Help is available in the configuration.nix(5) man page and in the NixOS manual
# (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  ...
}:
let
  k3sNodeToPrimary = {
    "cap-apollo-n03" = "cap-apollo-n02";
    "cap-apollo-n04" = "cap-apollo-n02";
    "cap-clust-02" = "cap-clust-01";
    "cap-clust-03" = "cap-clust-01";
  };

  isK3sPrimary = lib.lists.elem "${config.networking.hostName}" (
    lib.unique (lib.attrValues k3sNodeToPrimary)
  );
  serverAddr = if isK3sPrimary then "" else k3sNodeToPrimary.${config.networking.hostName};
  #
  #  testingFile = pkgs.writeTextFile {
  #    name = "testing_output.txt";
  #    text = ''
  #      TESTING OUTPUT
  #      isk3sPrimary: ${toString isK3sPrimary}
  #      serverAddr: ${toString serverAddr}
  #    '';
  #    destination = "/testing/testing_output.txt";
  #  };

in
{

  #  environment.systemPackages = with pkgs; [
  #    testingFile
  #  ];
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/caperren/caperren.nix

    # System Configuration
    ../../modules/system/cpu-amd.nix
    ../../modules/system/desktop.nix
    ../../modules/system/fonts.nix
    ../../modules/system/gpu-amd.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/pipewire.nix
    ../../modules/system/security.nix
    ../../modules/system/ssd.nix
    ../../modules/system/systemd-boot.nix

    # Application Groups
    ../../modules/application-groups/3d-design.nix
    ../../modules/application-groups/android.nix
    ../../modules/application-groups/downloads.nix
    ../../modules/application-groups/gaming.nix
    ../../modules/application-groups/hobby-rc.nix
    ../../modules/application-groups/homelab.nix
    ../../modules/application-groups/media.nix
    ../../modules/application-groups/media-creation.nix
    ../../modules/application-groups/pcb-design.nix
    ../../modules/application-groups/productivity.nix
    ../../modules/application-groups/programming.nix
    ../../modules/application-groups/radio.nix
    ../../modules/application-groups/social.nix
    ../../modules/application-groups/system-utilities.nix
    ../../modules/application-groups/virtualization.nix
    ../../modules/application-groups/web.nix
  ];

  networking.hostName = "cap-nr200p"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
