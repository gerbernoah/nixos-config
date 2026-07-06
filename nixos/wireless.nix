{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = false;

  networking.wireless = {
    enable = true;
    secretsFile = "/etc/nixos-secrets/wifi.env";
    
    networks."eduroam" = {
      auth = ''
        key_mgmt=WPA-EAP
        eap=PEAP
        identity="nogerber@student-net.ethz.ch"
        anonymous_identity="anonymous@ethz.ch"
        password=ext:eduroam_password
        phase2="auth=MSCHAPV2"
      '';
    };

    networks."coldspot".psk = "ext:coldspot_psk";
    # networks."home-ssid".pskRaw = "ext:home_wifi_psk";
  };
}
