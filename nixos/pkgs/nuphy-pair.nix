{ writeShellApplication, bluez, coreutils, gnugrep }:

# Re-pairs the NuPhy Air75 over Bluetooth.
#
# The keyboard picks a new random BLE address every time it re-enters pairing
# mode while unbonded; only the suffix is stable. A hardcoded address is always
# stale, and BlueZ drops discovered devices from its cache as soon as scanning
# stops -- so discovery and pairing have to happen in one bluetoothctl session
# with the scan still running.

writeShellApplication {
  name = "nuphy-pair";
  runtimeInputs = [ bluez coreutils gnugrep ];
  text = ''
    SUFFIX="''${NUPHY_SUFFIX:-00:50:00:9D:5D}"
    LOG=$(mktemp /tmp/nuphy-pair.XXXXXX)
    FIFO=$(mktemp -u /tmp/nuphy-fifo.XXXXXX)
    mkfifo "$FIFO"
    exec 3<>"$FIFO"           # read-write; opening write-only deadlocks
    trap 'rm -f "$FIFO"' EXIT

    stdbuf -oL bluetoothctl <&3 >>"$LOG" 2>&1 &

    send() { printf '%s\n' "$1" >&3; sleep 1; }

    sleep 2
    send "power on"
    send "scan on"

    echo ">>> Hold Fn+1 on the NuPhy until it blinks fast, then leave it alone."

    ADDR=""
    for _ in $(seq 1 30); do
      # grep exits 1 when absent; tolerate it so pipefail does not abort us
      ADDR=$(grep -aoE "[0-9A-F]{2}:$SUFFIX" "$LOG" | tail -1 || true)
      if [ -n "$ADDR" ]; then break; fi
      sleep 1
    done

    if [ -z "$ADDR" ]; then
      echo ">>> Never saw it advertise. Check the switch on the back is set to BT."
      send "quit"
      exit 1
    fi

    echo ">>> Live address: $ADDR"

    # Drop stale bonds for this same keyboard under previous addresses.
    OLD=$(bluetoothctl devices | grep -oE "[0-9A-F]{2}:$SUFFIX" || true)
    for old in $OLD; do
      if [ "$old" != "$ADDR" ]; then send "remove $old"; fi
    done

    send "remove $ADDR"
    send "pair $ADDR"
    sleep 12
    send "trust $ADDR"        # without this it will not auto-reconnect
    send "connect $ADDR"
    sleep 6
    send "quit"
    sleep 1

    echo ">>> Result:"
    bluetoothctl info "$ADDR" \
      | grep -iE "Name|Paired|Bonded|Trusted|Connected" || true
    grep -aiE "Pairing successful|Failed to pair|AuthenticationFailed" "$LOG" \
      | tail -3 || true
  '';
}
