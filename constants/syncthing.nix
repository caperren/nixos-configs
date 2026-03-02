let
  cap_apollo_n01 = {
    "cap-apollo-n01" = {
      id = "6YG34W5-52EXEAS-4RTGLCM-JOSGICK-M6QIRQS-OLLRWTF-HDZMNRP-ZJ24FAM";
    };
  };
  cap_nr200p = {
    "cap-nr200p" = {
      id = "EVP5ZRR-7ANGLAF-FILO7OY-MOYLSBJ-4RTADO2-I3MIWJU-WHCODDC-FPH7VQS";
    };
  };
  cap_slim7 = {
    "cap-slim7" = {
      id = "YSL2OXD-62M5Z6G-ID5LDD5-7MGHMTQ-3QTEXB4-NHOZIHH-5KX4F4B-6RIL5A4";
    };
  };
  android = {
    "android" = {
      id = "GTAF4KD-BTLBC7H-X2HRHLR-UFBU5B4-LE4TSYP-F2VKVV7-JASWFJQ-CT4B5AF";
    };
  };
in

{
  allDevices = cap_apollo_n01 // cap_nr200p // cap_slim7 // android;
  nonAndroidDevices = cap_apollo_n01 // cap_nr200p // cap_slim7;
}
