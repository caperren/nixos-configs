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
        users = [ "caperren" ];
        commands = [
          {
            command = "${pkgs.nvtopPackages.full}/bin/nvtop";
            options = [ "NOPASSWD" "SETENV" ];
          }
        ];

      }
    ];
  };
}
