# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/application-groups/gaming.nix
  ];

  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # 
  nix.settings.download-buffer-size = 524288000;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.configurationLimit = 8;

  networking.hostName = "cap-slim7"; # Define your hostname.  #-#
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  #security.sudo.extraConfig = ''
  #  Defaults        timestamp_timeout=15
  #'';

  #  security.polkit.extraConfig = ''
  #    polkit.addRule(function(action, subject) {
  #      if ((action.id == "org.freedesktop.login1.reboot" ||
  #          action.id == "org.freedesktop.login1.poweroff") &&
  #          subject.isInGroup("powerusers")) {
  #        return polkit.Result.YES;
  #      }
  #    });
  #  '';

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ]; # -#

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  # time.timeZone = "Pacific/Honolulu";
  #time.timeZone = "Europe/Oslo";
  # services.tzupdate.enable = true;

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

  # Install firefox.
  programs.firefox.enable = true; # -#

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #      droidcam-obs
    #     teensyduino
    #    ];
    #    plugins = with obs-studio-plugins; [
    # PKGS END
    # bottles
    # lenovo-legion
    obs-studio
    #(wrapOBS {
    #arduino-ide
    #audacity
    #deadbeef
    #dolphin-emu
    #dualsensectl
    #easyeffects
    #flameshot
    #gcc
    #glmark2
    #heroic
    #jetbrains.pycharm-professional
    #lf
    #lf
    #librewolf
    #lutris
    #meshcentral
    #pcb2gcode
    #projectm_3
    #python311Full
    #qemu
    #quickemu
    #rofi-bluetooth
    #s-tui
    #scrcpy
    #sox
    #stm32cubemx
    #stm32flash
    #teensy-udev-rules
    #transmission_4-qt
    #via
    #vlc
    #vscode
    #winetricks
    #})
    vlc
    alsa-utils
    arandr
    brightnessctl
    discord
    dnsutils
    git
    glava
    google-chrome
    htop
    hyprpicker
    iftop
    iotop
    jetbrains-toolbox
    flameshot
    jq
    kanshi
    killall
    mako
    ncdu
    networkmanager
    networkmanagerapplet
    nixfmt-rfc-style
    nodejs
    nvtopPackages.full
    obsidian
    pasystray
    pavucontrol
    playerctl
    podman
    powertop
    pulsemixer
    speedcrunch
    spotify-player
    streamdeck-ui
    telegram-desktop
    unetbootin
    unzip
    usbutils
    util-linux
    wget
    wl-clipboard
    wlogout
    wofi
    xfce.mousepad
    imagemagick
    hyprlock
    # plex-desktop
    darktable
    arduino
    yt-dlp
    nmap
    signal-desktop
    swayidle
    hyprlock
    pciutils
    s-tui
    woeusb
    gparted
  ];

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  #programs.adb.enable = true;
  services.meshcentral.enable = true;
  services.xserver.videoDrivers = [
    "displaylink"
    "modesetting"
  ];
  programs.ydotool.enable = true;

  #boot.extraModulePackages = with config.boot.kernelPackages; [
  #  v4l2loopback
  #];
  #boot.extraModprobeConfig = ''
  #  options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  #'';

  #programs.virt-manager.enable = true;
  #users.groups.libvirtd.members = [ "caperren" ];
  #virtualisation.libvirtd.enable = true;
  #virtualisation.spiceUSBRedirection.enable = true;
  #services.spice-vdagentd.enable = true;

  # services.automatic-timezoned.enable = true;

  programs.bash.shellAliases = {
    nixrebuild = "pushd /etc/nixos && { trap 'popd' EXIT; sudo nixos-rebuild switch --flake .#$(hostname); }";
    nixupdate = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#$(hostname)";
    nixedit = "sudo nano /etc/nixos/hosts/$(hostname)/configuration.nix";

    nixlimitfive = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | head -n -5 | cut -d ' ' -f2 | xargs -I {} sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system {}";
  };

  #programs.appimage = {
  #  enable = true;
  #  binfmt = true;
  #};

  #  services.power-profiles-daemon.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      ##### Defaults ######
      # WIFI
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";

      # AC
      CPU_MIN_PERF_ON_AC = 0;

      # BATT
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 35;

      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      START_CHARGE_THRESH_BAT0 = 1; # On non-thinkpad lenovo, this sets conservation mode to 0
      STOP_CHARGE_THRESH_BAT0 = 1; # ..., but to 1

      ###### Airplane Settings #####
      # AC
      #            CPU_MAX_PERF_ON_AC = 35;

      #            CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      #            CPU_ENERGY_PERF_POLICY_ON_AC = "power";

      ###### Normal Settings ######
      # AC
      CPU_MAX_PERF_ON_AC = 100;

      CPU_SCALING_GOVERNOR_ON_AC = "performanc";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      # BATT

      ##### Special Overrides #####
      #Optional helps save long term battery health
      #            START_CHARGE_THRESH_BAT0 = 0; # On non-thinkpad lenovo, this sets conservation mode to 0
      #            STOP_CHARGE_THRESH_BAT0 = 0; # ..., but to 1
    };
  };

  #hardware.keyboard.qmk.enable = true;
  #services.udev.packages = [ pkgs.via ];
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
