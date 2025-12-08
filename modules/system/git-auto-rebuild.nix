{ config, pkgs, ... }:
{
  systemd.services.git-auto-rebuild = {
    enable = true;
    after = [ "network.target" ];
    description = "Rebuilds the git repo at /etc/nixos if there are changes in the currently checked out branch";
    #        startAt = "*:0/1";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash -c 'cd /etc/nixos && ${pkgs.git}/bin/git pull && ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake #$(hostname)'";
    };

  };
}
