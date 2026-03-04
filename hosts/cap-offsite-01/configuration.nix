# Find disks with `ls -l /dev/disk/by-id/`
# Ensure you're not nuking your boot drive with `lsblk -o NAME,SIZE,MODEL,SERIAL,UUID`
# To create the data_offsite zfs pool, use the following example template
# sudo wipefs -a /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTFBH9Q && \
# sudo wipefs -a /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTDY6K9 && \
# sudo wipefs -a /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTEZANT && \
# sudo wipefs -a /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTAX092 && \
# sudo zpool labelclear -f /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTFBH9Q ; \
# sudo zpool labelclear -f /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTDY6K9 ; \
# sudo zpool labelclear -f /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTEZANT ; \
# sudo zpool labelclear -f /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTAX092 ; \
# sudo zpool create \
#   -o ashift=9 \
#   data_offsite \
#   raidz2 \
#   /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTFBH9Q \
#   /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTDY6K9 \
#   /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTEZANT \
#   /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTAX092 && \
# sudo zfs set compression=lz4 data_offsite && \
# sudo zfs set atime=off data_offsite && \
# sudo zfs set xattr=sa data_offsite && \
# sudo zpool scrub data_offsite && \
# sudo zpool status
#
# To add hot spare
# sudo wipefs -a /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTAW2BB && \
# sudo zpool labelclear -f /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTAW2BB ; \
# sudo zpool add data_offsite spare /dev/disk/by-id/ata-ST16000NE000-3UN101_ZVTAW2BB

{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Users
    ../../users/offsite-admin/offsite-admin-home-manager.nix

    # System Configuration
    ../../modules/system/fonts.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/security.nix
    ../../modules/system/server.nix
    ../../modules/system/ssd.nix
    ../../modules/system/systemd-boot.nix
    ../../modules/system/zfs.nix

    # Application Groups
    ../../modules/application-groups/system-utilities.nix

  ];

#  boot.loader.systemd-boot.graceful = true;

  networking.hostName = "cap-offsite-01";
  networking.hostId = "c5d7ab9f";

  time.timeZone = "America/Los_Angeles";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
