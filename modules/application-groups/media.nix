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

  programs.bash.shellAliases = {
    scrwebcam = "sudo pkill scrcpy ; sudo modprobe -r v4l2loopback ; sudo modprobe v4l2loopback && nohup scrcpy --camera-facing=back --video-source=camera --v4l2-sink=/dev/video0 --no-window --no-audio-playback 2>&1 1>/dev/null";
  };

  environment.systemPackages = with pkgs; [
    glava
    plex-desktop
    projectm_3
    sox
    spotify
    spotify-player
    vlc
  ];

}
