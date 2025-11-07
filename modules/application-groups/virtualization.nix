{ config, pkgs, ... }:
{

  virtualisation.containers.policy = {
    default = [ { type = "insecureAcceptAnything"; } ];

  };
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  environment.systemPackages = with pkgs; [
    distrobox
  ];

}
