{ pkgs, config, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # Fix waiting on vsync
    __GL_SYNC_TO_VBLANK = "0";
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };
  services.displayManager.gdm = {
      enable = true;
      wayland = true;
  };

#   services.displayManager.autoLogin = {
#     enable = true;
#     user = "caperren";
#  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    # Enable modesetting for Wayland compositors (hyprland)
    modesetting.enable = true;
    # Use the open source version of the kernel module (for driver 515.43.04+)
    # Actually, just overridden to false for now
    open = false;
    # Enable the Nvidia settings menu
    nvidiaSettings = true;
    # Select the appropriate driver version for your specific GPU
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  environment.systemPackages = [
    pkgs.hyprland
    pkgs.kitty
    pkgs.waybar
    pkgs.dunst
    pkgs.libnotify
    pkgs.rofi-wayland
    pkgs.nwg-look
    pkgs.desktop-file-utils
    pkgs.grim
    pkgs.slurp
    pkgs.nwg-displays

    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
