{ pkgs, ... }:
{
  # Support steam hardware like the index and steam controller
  hardware.steam-hardware.enable = true;

  # Steam
  programs.steam =
    let
      patchedBwrap = pkgs.bubblewrap.overrideAttrs (o: {
        patches = (o.patches or [ ]) ++ [
          ./bwrap.patch
        ];
      });
    in
    {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      package = pkgs.steam.override {
        buildFHSEnv = (
          args:
          (
            (pkgs.buildFHSEnv.override {
              bubblewrap = patchedBwrap;
            })
            (
              args
              // {
                extraBwrapArgs = (args.extraBwrapArgs or [ ]) ++ [ "--cap-add ALL" ];
              }
            )
          )
        );
        extraProfile = ''
          # Fixes timezones on VRChat
          unset TZ
          # Allows Monado to be used
          export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
        '';
      };
    };

  # Valve's micro-compositor
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Open source OpenXR runtime for VR
  services.monado = {
    enable = true;
    defaultRuntime = true;
    highPriority = true;
  };

  environment.systemPackages = with pkgs; [
    bs-manager
    heroic
    itch
    monado
    xrizer
  ];
}
