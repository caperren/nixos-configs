{ config, pkgs, ... }:
{
  fonts.fontDir.enable = true;
  fonts.fontconfig = {
    enable = true;
    antialias = true;
    defaultFonts = {
      monospace = [ "JetBrains Mono" ];
      sansSerif = [ "JetBrains Mono" ];
      serif = [ "JetBrains Mono" ];
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    jetbrains-mono
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    font-awesome
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
  ];
}
