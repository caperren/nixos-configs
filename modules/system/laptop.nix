{ config, pkgs, ... }:
{
  imports = [
    ./common.nix
  ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  services.blueman.enable = true; # Enables bluetooth manager
  hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller on boot

  environment.systemPackages = with pkgs; [
    brightnessctl
    powertop
  ];

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

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      # BATT

      ##### Special Overrides #####
      #Optional helps save long term battery health
      #            START_CHARGE_THRESH_BAT0 = 0; # On non-thinkpad lenovo, this sets conservation mode to 0
      #            STOP_CHARGE_THRESH_BAT0 = 0; # ..., but to 1
    };
  };
}
