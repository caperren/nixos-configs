{ config, pkgs, ... }:
{
  fileSystems."/mnt/nas_data_primary/Corwin" = {
    device = "cap-apollo-n01:/nas_data_primary/Corwin";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "noauto"
      "_netdev"
      "nofail"
    ];
  };
  fileSystems."/mnt/nas_data_primary/Media" = {
    device = "cap-apollo-n01:/nas_data_primary/Media";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "noauto"
      "_netdev"
      "nofail"
    ];
  };
}
