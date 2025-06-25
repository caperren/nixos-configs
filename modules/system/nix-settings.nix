{ config, pkgs, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Generally want a larger download buffer
  nix.settings.download-buffer-size = 524288000;

}
