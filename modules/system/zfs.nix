{ config, pkgs, ... }:
let
  notifyHelpers = import ../scripts/notify-helpers.nix { inherit pkgs; };
in
{
  boot.supportedFilesystems = [ "zfs" ];

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.zfs.zed.settings = {
    ZED_NOTIFY_VERBOSE = true;
  };
  systemd.services.zfs-zed.path = [
    pkgs.notify
    pkgs.zfs
    notifyHelpers.tgEscape
  ];

  environment.etc."zfs/zed.d/zed-tg-notify.sh" = {
    source = pkgs.writeShellScript "zed-tg-notify.sh" ''
      set -euo pipefail

      # Extract zevent data
      class="''${ZEVENT_CLASS:-unknown}"
      subclass="''${ZEVENT_SUBCLASS:-unknown}"
      pool="''${ZEVENT_POOL:-''${ZPOOL:-unknown}}"
      host="''${HOSTNAME:-''$(hostname)}"

      # Exit if the event kind isn't something we should notify on
      case "$class" in
        "sysevent.fs.zfs.statechange"|"sysevent.fs.zfs.vdev_fault"|"sysevent.fs.zfs.vdev_check"|"sysevent.fs.zfs.scrub_finish")
          ;;
        *)
          exit 0
          ;;
      esac

      # Telegram message base
      msg="ZFS event on ''${host}
      class: ''${class}
      subclass: ''${subclass}
      pool: ''${pool}"

      # Add pool health snapshots if any pools are unhealthy
      health="''$(${pkgs.zfs}/bin/zpool status -x 2>/dev/null || true)"
      if [ -n "$health" ]; then
        msg="$msg
        $health"
      fi

      # Send (escape MarkdownV2 first)
      printf '%s\n' "$msg" | ${notifyHelpers.tgEscape}/bin/tg-escape | ${pkgs.notify}/bin/notify
    '';
    mode = "0555";
  };
}
