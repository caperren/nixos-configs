{ pkgs, ... }:
{
  security.sudo = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
        ];
      }
      {
        users = [ "cluster-admin" ];
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl start git-auto-rebuild.service";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl stop git-auto-rebuild.service";
            options = [ "NOPASSWD" ];
          }

        ];
      }
      {
        users = [ "caperren" ];
        commands = [
          {
            command = "${pkgs.nvtopPackages.full}/bin/nvtop";
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
