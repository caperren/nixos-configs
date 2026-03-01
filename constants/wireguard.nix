{
  services = {
    host = "caperren.com";
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
    };
  };
}
