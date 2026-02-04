{ config, pkgs, ... }:
let
  notifyHelpers = import ../scripts/notify-helpers.nix { inherit pkgs; };
in
{
  boot.supportedFilesystems = [ "zfs" ];

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "monthly";
    };
    trim = {
      enable = true;
      interval = "weekly";
    };
  };

  services.sanoid = {
    enable = true;
    templates = {
      "critical_priority" = {
        autoprune = true;
        autosnap = true;

        daily = 30;
        hourly = 24;
        monthly = 12;
        yearly = 5;
      };
      "high_priority" = {
        autoprune = true;
        autosnap = true;

        daily = 14;
        hourly = 24;
        monthly = 6;
        yearly = 0;
      };
      "medium_priority" = {
        autoprune = true;
        autosnap = true;

        daily = 7;
        hourly = 12;
        monthly = 3;
        yearly = 0;
      };
      "low_priority" = {
        autoprune = true;
        autosnap = true;

        daily = 1;
        hourly = 1;
        monthly = 1;
        yearly = 0;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
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
