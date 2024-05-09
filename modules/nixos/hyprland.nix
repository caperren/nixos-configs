{ pkgs, config, ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

 environment.sessionVariables = {
    # If your cursor becomes invisible
    # WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  services.xserver = { 
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
  
  hardware.opengl = {  
    enable = true;  
    driSupport = true;  
    driSupport32Bit = true;  
  };

  hardware.nvidia = {
    # Enable modesetting for Wayland compositors (hyprland)
    modesetting.enable = true;
    # Use the open source version of the kernel module (for driver 515.43.04+)
    # open = true;
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

  #(pkgs.waybar.overrideAttrs (oldAttrs: {
  #    mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
  #  })
  #)
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
