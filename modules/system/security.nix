{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    sops
    age
  ];
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    defaultSopsFile = ../../secrets/default.yaml;
  };

  security.sudo = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "${config.system.path}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${config.system.path}/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
        ];
      }
      {
        users = [ "cluster-admin" ];
        commands = [
          {
            command = "${config.system.path}/bin/systemctl start git-auto-rebuild.service";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${config.system.path}/bin/systemctl stop git-auto-rebuild.service";
            options = [ "NOPASSWD" ];
          }

        ];
      }
      {
        users = [ "caperren" ];
        commands = [
          {
            command = "${config.system.path}/bin/nvtop";
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
