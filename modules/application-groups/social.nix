{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord
    slack
    telegram-desktop
  ];

  nixpkgs.overlays = [
    (_: prev: {
      telegram-desktop = prev.telegram-desktop.overrideAttrs (prevAttrs: {
        unwrapped = prevAttrs.unwrapped.overrideAttrs {
          patches = (prevAttrs.unwrapped.patches or [ ]) ++ [
            # https://github.com/NixOS/nixpkgs/issues/497549
            (prev.pkgs.fetchpatch {
              url = "https://gist.github.com/half-duplex/d95e4fda535fb72ad0246ccfbe55cb23/raw/410dc924a317d391226c338ab75fcd1a9aaaf91b/tdesktop-minizip-include.patch";
              hash = "sha256-lvEE5ZGmOjulZCg/rgrvAOTjUpJsAOcga+sAzr8FtYA=";
            })
          ];
        };
      });
    })
  ];
}
