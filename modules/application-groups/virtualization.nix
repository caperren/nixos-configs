{ config, pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  environment.systemPackages = with pkgs; [
    distrobox
  ];

}
