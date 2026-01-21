{ config, pkgs, ... }:
{
  imports = [
    # Hardware Scan
    ./hardware-configuration.nix

    # Host Groups
    ../../modules/host-groups/apollo-2000-k3s-cluster.nix
  ];

  networking.hostName = "cap-apollo-n02";
  networking.hostId = "bc7334b5";

  systemd = {
    services.usb-disconnect-watch = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "Sets zfs options post-boot";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "usb-disconnect-watch.sh" ''
          set -e

          PATTERN='usb 4-7: USB disconnect'
          LAST_FILE="/run/usb-disconnect-watch.last"
          DEBOUNCE_SECONDS=30

          echo "[usb-watch] starting; waiting for pattern: $PATTERN"

          journalctl -k -f -o cat | while IFS= read -r line; do
            # Match the log line (prefix match is usually safest for kernel messages)
            if echo "$line" | grep -qE "^$PATTERN*"; then
              now="$(date +%s)"

              if [ -f "$LAST_FILE" ]; then
                last="$(cat "$LAST_FILE" || echo 0)"
                if [ "$((now - last))" -lt "$DEBOUNCE_SECONDS" ]; then
                  echo "[usb-watch] disconnected, waiting for $DEBOUNCE_SECONDS second debounce to complete"
                  sleep 5
                  continue
                fi
              fi

              echo "$now" > "$LAST_FILE"
              echo "[usb-watch] disconnect detected: $line"
              echo "Deleting pods dependent on USB"

              echo "Killing zwave"
              kubectl delete pod -l app.kubernetes.io/name=zwave-js-ui --ignore-not-found=true || true

              echo "Killing home assistant"
              kubectl delete pod -l app.kubernetes.io/name=home-assistant --ignore-not-found=true || true

              echo "[usb-watch] kubectl deletes issued"
            fi
          done
        ''}";

      };

      path = with pkgs; [
        coreutils
        gnugrep
        kubectl
        systemc
      ];
    };
  };
}
