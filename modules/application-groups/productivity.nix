{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
    kdePackages.okular
    texliveFull
  ];
}
