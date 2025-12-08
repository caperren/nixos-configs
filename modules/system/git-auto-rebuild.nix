{ config, pkgs, ... }:
{
  systemd.services.git-auto-rebuild = {
    enable = true;
    after = [ "network.target" ];
    description = "Rebuilds the git repo at /etc/nixos if there are changes in the currently checked out branch";
    #        startAt = "*:0/1";
    serviceConfig = {
      Type = "simple";
      ExecStart = "/run/current-system/sw/bin/bash -c 'cd /etc/nixos && /run/current-system/sw/bin/git pull && /run/current-system/sw/bin/nixos-rebuild switch --flake #$(hostname)'";
    };

  };
}
