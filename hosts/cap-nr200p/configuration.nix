# Edit this configuration file to define what should be installed on your system.
# Help is available in the configuration.nix(5) man page and in the NixOS manual
# (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/application-groups/gaming.nix
  ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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

  #
  nix.settings.download-buffer-size = 524288000;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "cap-nr200p"; # Define your hostname.  #-#
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # hardware.u2f.enable = true;

  services.flatpak.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ]; # -#

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
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
      #  thunderbird
    ];
  };
  #  users.users.crestline = {
  #    isNormalUser = true;
  #    description = "Crestline";
  #    extraGroups = [
  #      "networkmanager"
  #      "wheel"
  #      "input"
  #      "dialout"
  #    ];
  #    packages = with pkgs; [
  #      #  thunderbird
  #    ];

  # };

  #services.displayManager.autoLogin = {
  #   enable = true;
  #   user = "crestline";
  #};

  #services.xserver.displayManager.gdm.autoLogin.delay = 60;

  # Install firefox.
  programs.firefox.enable = true; # -#

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    lf
    git
    wofi
    nvtopPackages.full
    htop
    iftop
    iotop
    pulsemixer
    arandr
    util-linux
    usbutils
    telegram-desktop
    discord
    # spotify
    vscode-with-extensions
    swayimg
    pavucontrol
    networkmanagerapplet
    pasystray
    glava
    spotify-player
    hyprpicker
    unetbootin
    lf
    dnsutils
    unzip
    playerctl
    google-chrome
    killall
    #jetbrains.pycharm-professional
    wget
    jq
    rofi-bluetooth
    wl-clipboard
    networkmanager
    alsa-utils
    nixfmt-rfc-style
    mako
    podman
    kicad
    obsidian
    speedcrunch
    deadbeef
    vlc
    sox
    audacity
    platformio

    # flatcam
    pcb2gcode
    jetbrains-toolbox
    arduino-ide
    # python311Full
    gcc
    stm32cubemx
    stm32flash
    easyeffects
    ncspot
    #yubikey-personalization-gui
    #yubikey-manager-qt
    #zoom-us
    mangohud
    distrobox
    # plex-desktop
    rpi-imager
    rpiboot
    imagemagick
    prusa-slicer
    freecad
    wlogout
    gparted
    nix-update
    ffmpeg-full
    projectm_3
    heroic
    flameshot
    krename
    xfce.mousepad
    yt-dlp
    soapysdr
    soapyrtlsdr
    # sdrpp
    # brave
    python3
    #nodejs_23
    streamdeck-ui
    scrcpy
    kanshi
    #wsmancli
    #realvnc-vnc-viewer
    ncdu
    hyprlock
    openrgb-with-all-plugins
    swayidle
    transmission_4-qt
    nixos-generators
    openwsman
    wsmancli
    bs-manager
  ];

  services.monado = {
    enable = true;
    defaultRuntime = true;
    highPriority = true;
  };

  services.hardware.openrgb.enable = true;

  services.meshcentral.enable = true;
  programs.ydotool.enable = true;
  programs.adb.enable = true;

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;

  };

  programs.bash.shellAliases = {
    nixrebuild = "pushd /etc/nixos && { trap 'popd' EXIT; sudo nixos-rebuild switch --flake .#$(hostname); }";
    nixupdate = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#$(hostname)";
    nixedit = "sudo nano /etc/nixos/hosts/$(hostname)/configuration.nix";

    nixlimitfive = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | head -n -5 | cut -d ' ' -f2 | xargs -I {} sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system {}";

    scrwebcam = "sudo pkill scrcpy ; sudo modprobe -r v4l2loopback ; sudo modprobe v4l2loopback && nohup scrcpy --camera-facing=back --video-source=camera --v4l2-sink=/dev/video0 --no-window --no-audio-playback 2>&1 1>/dev/null";
  };

  virtualisation.waydroid.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  services.udev.extraRules = ''
    # ST-LINK V2
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2_%n"

    # ST-LINK V2.1
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2-1_%n"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv2-1_%n"

    # ST-LINK V3
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3loader_%n"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="600", TAG+="uaccess", SYMLINK+="stlinkv3_%n"

    # CP2101 - CP 2104
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="600", TAG+="uaccess", SYMLINK+="usb2ser_%n"

    # ATEN UC-232A
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0557", ATTRS{idProduct}=="2008", MODE="600", TAG+="uaccess", SYMLINK+="usb2ser_aten_%n"
  '';

  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;
  fonts.fontconfig.antialias = true;
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

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  hardware.rtl-sdr.enable = true;

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true; # -#

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
