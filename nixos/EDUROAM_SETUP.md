# eduroam setup — remaining steps (run after restart)

Config changes already made (before restart):
- `nixos/wireless.nix` created: NetworkManager disabled, `networking.wireless`
  (wpa_supplicant) enabled, `eduroam` network defined (PEAP/MSCHAPv2), reads
  secrets from `/etc/nixos-secrets/eduroam.env` via `@EDUROAM_IDENTITY@` /
  `@EDUROAM_PASSWORD@` placeholders.
- `nixos/configuration.nix` updated to import `./wireless.nix` and no longer
  sets `networking.networkmanager.enable` itself.

## 1. Create the root-only secrets file (outside git, never committed)

```bash
sudo mkdir -p /etc/nixos-secrets
sudo touch /etc/nixos-secrets/eduroam.env
sudo chmod 600 /etc/nixos-secrets/eduroam.env
sudo chown root:root /etc/nixos-secrets/eduroam.env
```

## 2. Pull identity/password from 1Password ("ETH Radius" item) into that file

```bash
sudo sh -c 'cat > /etc/nixos-secrets/eduroam.env <<EOF
EDUROAM_IDENTITY=$(op item get "ETH Radius" --fields username)
EDUROAM_PASSWORD=$(op item get "ETH Radius" --fields password --reveal)
EOF'
```

## 3. Rebuild

```bash
sudo nixos-rebuild switch --flake ~/nixos-config/nixos#nix-frame
```

## 4. Verify

```bash
wpa_cli status                  # want: wpa_state=COMPLETED
journalctl -u wpa_supplicant -f # watch for CTRL-EVENT-CONNECTED / EAP-SUCCESS
ip a                             # confirm you got an IP via DHCP
```

## Open items / decisions not yet made

1. **Other WiFi networks (home, hotspot, etc.) will stop auto-connecting**
   once NetworkManager is off. Add them to `networking.wireless.networks` in
   `wireless.nix`, e.g.:
   ```nix
   networks."home-ssid".psk = "@HOME_WIFI_PSK@";
   ```
   (and add the corresponding `HOME_WIFI_PSK=...` line to the secrets env file).
2. `users.users.ngerber.extraGroups` in `configuration.nix` still lists
   `"networkmanager"` — harmless now but no longer needed; remove if you want.
3. No CA cert is pinned for the eduroam RADIUS server (per earlier choice) —
   weaker against a rogue AP. Can add `ca_cert = "/path/to/eth-ca.pem";` to
   the `eduroam` network block later to harden it.
