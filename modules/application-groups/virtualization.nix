{ config, pkgs, ... }:
{

  virtualisation.docker.enable = true;
  virtualisation.containers.policy = {
    default = [ { type = "insecureAcceptAnything"; } ];

  };

}
