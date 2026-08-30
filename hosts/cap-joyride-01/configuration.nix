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
#  wireguardServicesConfig = (import ../../constants/wireguard.nix).services;
in
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/caperren/caperren-home-manager.nix

    # System Configuration
    ../../modules/system/cpu-intel.nix
    ../../modules/system/desktop.nix
    ../../modules/system/fonts.nix
    ../../modules/system/gpu-intel.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/monitoring-and-metrics.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/pipewire.nix
    ../../modules/system/security.nix
    ../../modules/system/ssd.nix
    ../../modules/system/systemd-boot.nix

    # Application Groups
    ../../modules/application-groups/boating.nix
    ../../modules/application-groups/downloads.nix
    ../../modules/application-groups/gaming.nix
    ../../modules/application-groups/media.nix
    ../../modules/application-groups/media-creation.nix
    ../../modules/application-groups/productivity.nix
    ../../modules/application-groups/programming.nix
    ../../modules/application-groups/radio.nix
    ../../modules/application-groups/system-utilities.nix
    ../../modules/application-groups/virtualization.nix
    ../../modules/application-groups/web.nix
  ];

  networking.hostName = "cap-joyride-01"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  networking = {
    firewall.enable = false;
    useNetworkd = true;
  };

  systemd.network = {
   enable = true;
   netdevs = {
     "30-br0" = {
       netdevConfig = {
         Kind = "bridge";
         Name = "br0";
         MACAddress = "none";
       };
     };
   };
   networks = {
     "30-enp1s0" = {
       name = "enp1s0";
       DHCP = "no";
       networkConfig = {
         IPv6AcceptRA = false;
         LinkLocalAddressing = "no";
       };
       linkConfig.RequiredForOnline = "no";
     };
     "30-enp2s0" = {
       name = "enp2s0";
       DHCP = "no";
       networkConfig = {
         IPv6AcceptRA = false;
         LinkLocalAddressing = "no";
       };
       linkConfig.RequiredForOnline = "no";
     };
     "30-enp3s0" = {
       name = "enp3s0";
       DHCP = "no";
       networkConfig = {
         IPv6AcceptRA = false;
         LinkLocalAddressing = "no";
       };
       linkConfig.RequiredForOnline = "no";
     };
     "30-enp4s0" = {
       name = "enp4s0";
       bridge = [ "br0" ];
       networkConfig = {
         IPv6AcceptRA = false;
         LinkLocalAddressing = "no";
       };
       linkConfig.RequiredForOnline = "enslaved";
     };
     "30-enp5s0" = {
       name = "enp5s0";
       bridge = [ "br0" ];
       networkConfig = {
         IPv6AcceptRA = false;
         LinkLocalAddressing = "no";
       };
       linkConfig.RequiredForOnline = "enslaved";
     };
     "30-enp8s0" = {
       name = "enp8s0";
       bridge = [ "br0" ];
       networkConfig = {
         IPv6AcceptRA = false;
         LinkLocalAddressing = "no";
       };
       linkConfig.RequiredForOnline = "enslaved";
     };
     "30-br0" = {
       name = "br0";
       DHCP = "yes";
       dhcpV4Config.UseDomains = true;
       ipv6AcceptRAConfig.UseDNS = true;
       dhcpV6Config.UseDNS = true;
       linkConfig.RequiredForOnline = "routable";
     };
   };
   links = {
     "30-br0" = {
       matchConfig.OriginalName = "br0";
       linkConfig.MACAddressPolicy = "none";
     };
   };
  };

#  services.ollama = {
#    package = pkgs.ollama-vulkan;
#    environmentVariables = {
#      GGML_VK_VISIBLE_DEVICES = "0";
#    };
#  };
#  services.open-webui = {
#    host = "127.0.0.1";
#  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
