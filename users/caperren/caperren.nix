{ config, pkgs, ... }:
{
  users.users.caperren = {
    isNormalUser = true;
    description = "Corwin Perren";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "dialout"
      "plugdev"
      "adbusers"
    ];
    packages = with pkgs; [
      obsidian
    ];
  };
}
