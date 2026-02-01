{ config, pkgs, ... }:
let
  nfsOptions = [
    "x-systemd.automount"
    "x-systemd.idle-timeout=600"
    "noauto"
    "_netdev"
    "nofail"
    "nfsvers=4.0"
  ];
in
{
  fileSystems."/mnt/nas_data_primary/ad" = {
    device = "cap-apollo-n01:/nas_data_primary/ad";
    fsType = "nfs";
    options = nfsOptions;
  };
  fileSystems."/mnt/nas_data_primary/caperren" = {
    device = "cap-apollo-n01:/nas_data_primary/caperren";
    fsType = "nfs";
    options = nfsOptions;
  };
  fileSystems."/mnt/nas_data_primary/komga" = {
    device = "cap-apollo-n01:/nas_data_primary/komga";
    fsType = "nfs";
    options = nfsOptions;
  };
  fileSystems."/mnt/nas_data_primary/long_term_storage" = {
    device = "cap-apollo-n01:/nas_data_primary/long_term_storage";
    fsType = "nfs";
    options = nfsOptions;
  };
  fileSystems."/mnt/nas_data_primary/media" = {
    device = "cap-apollo-n01:/nas_data_primary/media";
    fsType = "nfs";
    options = nfsOptions;
  };
}
