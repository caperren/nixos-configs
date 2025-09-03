{ config, pkgs, ... }:
let
  jetbrainsToolboxDesktopEntry = pkgs.writeTextFile {
    name = "jetbrains-toolbox-desktop";
    destination = "/share/applications/jetbrains-toolbox.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=JetBrains Toolbox
      Exec=jetbrains-toolbox
      Icon=jetbrains-toolbox
      Terminal=false
      Categories=Development;IDE;
    '';
  };
in {
  environment.systemPackages = with pkgs; [
    arduino-ide
    gcc
    jetbrains-toolbox
    jetbrainsToolboxDesktopEntry
    nix-update
    nixfmt-rfc-style
    nixos-generators
    nodejs
    # platformio
    python3Full
    stm32cubemx
    stm32flash
    teensy-udev-rules
    vscode-with-extensions
  ];

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

}
