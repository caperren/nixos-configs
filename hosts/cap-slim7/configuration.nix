# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Users
    ../../users/caperren/caperren.nix

    # System Configuration
    ../../modules/system/cpu-amd.nix
    ../../modules/system/displaylink.nix
    ../../modules/system/fonts.nix
    ../../modules/system/gpu-amd.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/laptop.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/pipewire.nix
    ../../modules/system/security.nix
    ../../modules/system/systemd-boot.nix

    # Application Groups
    ../../modules/application-groups/3d-design.nix
    ../../modules/application-groups/android.nix
    ../../modules/application-groups/downloads.nix
    ../../modules/application-groups/gaming.nix
    ../../modules/application-groups/homelab.nix
    ../../modules/application-groups/media.nix
    ../../modules/application-groups/pcb-design.nix
    ../../modules/application-groups/productivity.nix
    ../../modules/application-groups/programming.nix
    ../../modules/application-groups/social.nix
    ../../modules/application-groups/system-utilities.nix
    ../../modules/application-groups/virtualization.nix
    ../../modules/application-groups/web.nix
  ];

  networking.hostName = "cap-slim7"; # Define your hostname.  #-#

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  # time.timeZone = "Pacific/Honolulu";

  programs.bash.shellAliases = {
    nixrebuild = "pushd /etc/nixos && { trap 'popd' EXIT; sudo nixos-rebuild switch --flake .#$(hostname); }";
    nixupdate = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#$(hostname)";
    nixedit = "sudo nano /etc/nixos/hosts/$(hostname)/configuration.nix";

    nixlimitfive = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | head -n -5 | cut -d ' ' -f2 | xargs -I {} sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system {}";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
