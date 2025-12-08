{ pkgs, config, ... }:
{
  security.sudo = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
        ];
      }
      {
        users = [ "cluster-admin" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/systemctl start git-auto-rebuild.service";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl stop git-auto-rebuild.service";
            options = [ "NOPASSWD" ];
          }

        ];
      }
      {
        users = [ "caperren" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nvtop";
            options = [
              "NOPASSWD"
              "SETENV"
            ];
          }
        ];

      }
    ];
  };
}
