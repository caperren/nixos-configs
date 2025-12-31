{ config, pkgs, ... }:

{
  imports = [
    # Users
    ../../users/apollo-admin/apollo-admin.nix

    # System Configuration
    ../../modules/system/cpu-intel.nix
    ../../modules/system/fonts.nix
    ../../modules/system/home-manager-settings.nix
    ../../modules/system/internationalization.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix-settings.nix
    ../../modules/system/security.nix
    ../../modules/system/systemd-boot.nix

    # Application Groups
    ../../modules/application-groups/system-utilities-cluster.nix
    ../../modules/application-groups/virtualization.nix
  ];

  time.timeZone = "America/Los_Angeles";

  sops.secrets = {
    "ssh/ilouser/id_rsa" = {
      sopsFile = ../../secrets/default.yaml;
      path = "/root/.ssh/ilo_id_rsa";
      restartUnits = [ "hpe-silent-fans.service" ];
    };
    "ssh/ilouser/id_rsa_pub" = {
      sopsFile = ../../secrets/default.yaml;
      path = "/root/.ssh/ilo_id_rsa.pub";
    };
  };

  systemd = {
    services.hpe-ilo-keepalive = {
      enable = true;
      after = [
        "network.target"
        "hpe-silent-fans.service"
      ];
      wantedBy = [ "multi-user.target" ];
      description = "Maintains ilo ssh session via sending periodic command";

      serviceConfig = {
        Type = "simple";
        ExecStart = ''screen -S ilofansession -X stuff "fan info^M"'';
      };

      path = with pkgs; [
        bash
        config.programs.ssh.package
        screen
      ];

      startAt = "*:0/5";
    };
    services.hpe-silent-fans = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "Lowers fan speeds by using ilo over ssh to manually set fan parameters";

      serviceConfig = {
        Type = "simple";
        ExecStartPre = ''${pkgs.coreutils}/bin/sleep 30'';
        ExecStart = "${pkgs.writeShellScript "hpe-silent-fans.sh" ''
          set -e

          SCREEN_NAME=ilofansession

          SSH_USER=ilouser
          SSH_HOST=cap-apollo-ilo02
          SSH_KEY=/root/.ssh/ilo_id_rsa
          SSH_OPTIONS="-o KexAlgorithms=diffie-hellman-group14-sha1,diffie-hellman-group1-sha1 -o PubkeyAcceptedKeyTypes=+ssh-rsa -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no"

          # Create screen session
          screen -dmS $SCREEN_NAME

          # Make initial iLO connection
          screen -S $SCREEN_NAME -X stuff "ssh -i $SSH_KEY -t $SSH_USER@$SSH_HOST $SSH_OPTIONS^M"

          sleep 5

          ##### Tune pid for all non-segmented fans
          for sensor in 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16 17 18 19 20 21 26 28 29 30 31 32 38 40 41; do
            screen -S $SCREEN_NAME -X stuff "fan pid $sensor lo 1600^M"
            sleep 0.5
          done

          ##### Tune pid for segmented fans
          for sensor in 8 22 23 24 25 27 39; do
            screen -S $SCREEN_NAME -X stuff "fan a $sensor 0 0 16 41 16 25^M"
            sleep 0.5
          done

          ##### Set minimum for fan group
          screen -S $SCREEN_NAME -X stuff "fan p 0 min 16^M"
        ''}";

      };

      path = with pkgs; [
        bash
        config.programs.ssh.package
        coreutils
        screen
      ];
    };

    #    timers.hpe-ilo-keepalive = {
    #      wantedBy = [ "timers.target" ];
    #      timerConfig = {
    #        OnBootSec = "5m";
    #        OnCalendar = "*-*-* *:0/5:00";
    #        Unit = "hpe-ilo-keepalive.service";
    #      };
    #    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
