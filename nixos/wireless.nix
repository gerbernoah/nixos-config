{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = false;

  networking.wireless = {
    enable = true;
    # Secrets are substituted in at service-start time via wpa_supplicant's
    # ext:NAME mechanism, from a root-only file that lives outside the repo:
    # /etc/nixos-secrets/eduroam.env (create it yourself, see EDUROAM_SETUP.md).
    # Values in that file are literal (no quotes/escaping), so the actual
    # identity/password never land in this repo or the Nix store.
    secretsFile = "/etc/nixos-secrets/eduroam.env";

    networks."eduroam" = {
      # ETH Zurich eduroam: WPA2/3-Enterprise, PEAP + MSCHAPv2.
      # No CA cert pinned here (per instruction) - this accepts any CA-signed
      # server cert, which is weaker against a rogue AP than pinning ETH's
      # RADIUS CA. Add `ca_cert = "/path/to/eth-ca.pem";` later to harden it.
      auth = ''
        key_mgmt=WPA-EAP
        eap=PEAP
        identity=ext:eduroam_identity
        anonymous_identity="anonymous@ethz.ch"
        password=ext:eduroam_password
        phase2="auth=MSCHAPV2"
      '';
    };

    # Any other WiFi networks you rely on (home, phone hotspot, etc.) need to
    # be added here too now that NetworkManager is off, e.g.:
    # networks."home-ssid".pskRaw = "ext:home_wifi_psk";
  };
}
