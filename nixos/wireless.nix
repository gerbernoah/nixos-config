{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = false;

  networking.wireless = {
    enable = true;
    # Secrets are substituted in at service-start time from a root-only file
    # that lives outside the repo (see /etc/nixos-secrets/eduroam.env), so the
    # actual identity/password never land in this repo or the Nix store.
    environmentFile = "/etc/nixos-secrets/eduroam.env";

    networks."eduroam" = {
      # ETH Zurich eduroam: WPA2/3-Enterprise, PEAP + MSCHAPv2.
      # No CA cert pinned here (per instruction) - this accepts any CA-signed
      # server cert, which is weaker against a rogue AP than pinning ETH's
      # RADIUS CA. Add `ca_cert = "/path/to/eth-ca.pem";` later to harden it.
      auth = ''
        key_mgmt=WPA-EAP
        eap=PEAP
        identity="@EDUROAM_IDENTITY@"
        anonymous_identity="anonymous@ethz.ch"
        password="@EDUROAM_PASSWORD@"
        phase2="auth=MSCHAPV2"
      '';
    };

    # Any other WiFi networks you rely on (home, phone hotspot, etc.) need to
    # be added here too now that NetworkManager is off, e.g.:
    # networks."home-ssid".psk = "@HOME_WIFI_PSK@";
  };
}
