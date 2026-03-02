{
  services = {
    host = "5.78.42.43";
    port = 51820;
    mtu = 1420;
    persistentKeepalive = 25;

    allowedIPs = [ "10.8.0.0/24" ];
    peers = {
      "cap-hetz-01" = {
        address = "10.8.0.1";
        publicKey = "tebPeumSbNHyY4jXznDPus+CrS75kcFXc5C0be0apmE=";
      };
      "cap-slim7" = {
        address = "10.8.0.2";
        publicKey = "9DRHIl2r/iMGrsMO3e/cKea/Jtp5QhXjgvP8ci5k9wI=";
      };
      "cap-nr200p" = {
        address = "10.8.0.3";
        publicKey = "";
      };
      "cap-apollo-n02" = {
        address = "10.8.0.4";
        publicKey = "r9AUAWyw9fOF3w9O414iyzPiarJX3bYoQaNfkWJBEx0=";
      };
      "cap-apollo-n03" = {
        address = "10.8.0.5";
        publicKey = "nR68Rb/AZ+TWPSYCq+l+Es/yW1c3vbVLF2rWMwYs9GU=";
      };
      "cap-apollo-n04" = {
        address = "10.8.0.6";
        publicKey = "ZyhdQ7Q9a6Xg2IHlYeN7K8sOlMGgc6OvOaG/Nwx7W1M=";
      };

    };
  };
}
