{ config, pkgs, ... }:
{
  fileSystems."/mnt/nas_data_primary/caperren" = {
    device = "cap-apollo-n01:/nas_data_primary/caperren";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "noauto"
      "_netdev"
      "nofail"
      "nfsvers=4.0"
    ];
  };
  fileSystems."/mnt/nas_data_primary/media" = {
    device = "cap-apollo-n01:/nas_data_primary/media";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "noauto"
      "_netdev"
      "nofail"
      "nfsvers=4.0"
    ];
  };
}
