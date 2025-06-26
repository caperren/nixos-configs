{ config, pkgs, ... }:
{
  boot = {
    # Make v4l2loopback kernel module available to NixOS.
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    # Activate kernel module(s).
    kernelModules = [
      # Virtual camera.
      "v4l2loopback"
      # Virtual Microphone. Custom DroidCam v4l2loopback driver needed for audio.
      # "snd-aloop"
    ];
  };

  boot.extraModprobeConfig = ''
    # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
    # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
    # https://github.com/umlaeute/v4l2loopback
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
  '';

  environment.systemPackages = with pkgs; [
    deadbeef
    vlc
    sox
    audacity
    glava
    spotify-player
    projectm_3
    obs-studio
    darktable

    # Encountering build failures
    # plex-desktop
  ];

}
