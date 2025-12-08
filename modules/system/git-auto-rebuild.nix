{ config, pkgs, ... }:
{
  systemd.services.git-auto-rebuild = {
    enable = true;
    after = [ "network.target" ];
    description = "Rebuilds the git repo at /etc/nixos if there are changes in the currently checked out branch";
    #        startAt = "*:0/1";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${pkgs.bash}/bin/bash -c "cd /etc/nixos && ${pkgs.git}/bin/git pull && ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake \#$(${pkgs.hostname}/bin/hostname)"'';
    };
    environment =
      config.nix.envVars
      // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/root";
      }
      // config.networking.proxy.envVars;
    path = with pkgs; [
      bash
      coreutils
      gnutar
      hostname
      xz.bin
      gzip
      gitMinimal
      config.nix.package.out
      config.programs.ssh.package
    ];
  };

}
