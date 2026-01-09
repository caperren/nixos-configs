{ config, pkgs, ... }:
let
  # Match "cap-apollo-n02" → [ "cap-apollo" "02" ]
  match = builtins.match "^(.*)-n([0-9]+)$" config.networking.hostName;

  iloHost =
    if match == null then
      throw "Unexpected hostname format: ${config.networking.hostName}"
    else
      "${builtins.elemAt match 0}-ilo${builtins.elemAt match 1}";
in
{
  sops.secrets = {
    "ssh/ilouser/id_rsa" = {
      sopsFile = ../../secrets/default.yaml;
      path = "/root/.ssh/ilo_id_rsa";
    };
    "ssh/ilouser/id_rsa_pub" = {
      sopsFile = ../../secrets/default.yaml;
      path = "/root/.ssh/ilo_id_rsa.pub";
    };
  };

  systemd = {
    services.hpe-silent-fans = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "Lowers fan speeds by using ilo over ssh to manually set fan parameters";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "hpe-silent-fans.sh" ''
          set -e

          SCREEN_NAME=ilofansession

          SSH_USER=ilouser
          SSH_HOST=${iloHost}
          SSH_KEY=/root/.ssh/ilo_id_rsa
          SSH_OPTIONS="-o KexAlgorithms=diffie-hellman-group14-sha1,diffie-hellman-group1-sha1 -o PubkeyAcceptedKeyTypes=+ssh-rsa -o HostKeyAlgorithms=ssh-rsa -o StrictHostKeyChecking=no"

          # Wait for ilo host to be available
          while [ ! `ping -c 1 ${iloHost}` ]; do
            sleep 5
          done

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
          # When you type the command `fan a` it gives the following usage:
          #
          # alg: alg ALG PIECE TYPE LOW HIGH ARG1 ARG2
          #
          # ALG is the number of the algorithm (in my case 0)
          # PIECE is the segment (starting at 0)
          # TYPE I don't know what it does but setting it to 0 works
          # LOW is the min temp of the range (wihtout decimals so only write 10 for 10.00C)
          # HIGH is the max temp of the range (wihtout decimals so only write 20 for 20.00C)
          # ARG1 is the min PWM (no conversion required the plain number between 0-255)
          # ARG2 is the max PWM (no conversion required the plain number between 0-255)
          for sensor in 8 22 23 24 25 27 39; do
            screen -S $SCREEN_NAME -X stuff "fan a $sensor 0 0 16 41 16 25^M"
            sleep 0.5
          done

          ##### Set minimum for fan group
          screen -S $SCREEN_NAME -X stuff "fan p 0 min 16^M"
        ''}";

      };
      startAt = "*:0/30";

      path = with pkgs; [
        bash
        config.programs.ssh.package
        coreutils
        iputils
        screen
      ];
    };
  };
}
