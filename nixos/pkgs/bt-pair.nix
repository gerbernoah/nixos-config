{ writeShellApplication, bluez, coreutils, gnugrep, gnused }:

# Pairs a Bluetooth LE device by its advertised name.
#
# BLE peripherals (NuPhy Air75, Logitech MX Master 4, ...) pick a new random
# address every time they re-enter pairing mode while unbonded, so only the name
# is stable -- a hardcoded address is always stale. Worse, BlueZ drops
# discovered-but-unbonded LE devices from its cache the moment scanning stops,
# so "scan, read address, then pair" can never work: the address dies with the
# scan. Discovery and pairing have to happen in one bluetoothctl session with
# the scan still running.
#
# Usage: bt-pair "MX Master 4"
#        bt-pair "Air75 V3-1"

writeShellApplication {
  name = "bt-pair";
  runtimeInputs = [ bluez coreutils gnugrep gnused ];
  text = ''
    NAME="''${1:-}"
    if [ -z "$NAME" ]; then
      echo "usage: bt-pair <advertised name>   e.g. bt-pair \"MX Master 4\"" >&2
      exit 2
    fi

    LOG=$(mktemp /tmp/bt-pair.XXXXXX)
    FIFO=$(mktemp -u /tmp/bt-fifo.XXXXXX)
    mkfifo "$FIFO"
    exec 3<>"$FIFO"           # read-write; opening write-only deadlocks
    trap 'rm -f "$FIFO"' EXIT

    stdbuf -oL bluetoothctl <&3 >>"$LOG" 2>&1 &

    send() { printf '%s\n' "$1" >&3; sleep 1; }
    strip() { sed -r 's/\x1B\[[0-9;]*[mK]//g' "$LOG"; }
    MACRE="[0-9A-F]{2}(:[0-9A-F]{2}){5}"
    macs() { grep -aoE "$MACRE" || true; }

    sleep 2
    send "power on"
    send "scan on"

    echo ">>> Put '$NAME' into pairing mode (hold its pair/channel button until"
    echo ">>> it blinks fast), then leave it alone."

    ADDR=""
    ADVERTISING=no
    for _ in $(seq 1 40); do
      # grep exits 1 when absent; tolerate it so pipefail does not abort us
      ADDR=$(strip | grep -aoE "Device $MACRE (Name: |Alias: )?$NAME\$" | macs | tail -1 || true)
      if [ -n "$ADDR" ]; then ADVERTISING=yes; break; fi
      sleep 1
    done

    # A device that is already connected stops advertising, so the scan above
    # finds nothing. Fall back to the cache, which still holds it in that case.
    if [ -z "$ADDR" ]; then
      ADDR=$(bluetoothctl devices | grep -aoE "Device $MACRE $NAME\$" | macs | tail -1 || true)
      if [ -n "$ADDR" ]; then
        echo ">>> Not advertising, but already known. Using the cached entry and"
        echo ">>> leaving the existing bond intact."
      fi
    fi

    if [ -z "$ADDR" ]; then
      echo ">>> Never saw it advertise. Check it is in Bluetooth mode, and that"
      echo ">>> the name matches exactly (see: bluetoothctl devices)."
      send "quit"
      exit 1
    fi

    echo ">>> Address: $ADDR (advertising: $ADVERTISING)"

    # Only rebuild bonds when the device is actually in pairing mode. Tearing a
    # bond down otherwise would break a working device with no way to redo it,
    # since a non-advertising device cannot be paired again.
    if [ "$ADVERTISING" = yes ]; then
      # Drop stale bonds left behind under this device's previous addresses.
      OLD=$(bluetoothctl devices Paired | grep -aoE "Device $MACRE $NAME\$" | macs || true)
      for old in $OLD; do
        if [ "$old" != "$ADDR" ]; then
          echo ">>> Dropping stale bond $old"
          send "remove $old"
        fi
      done

      # Only tear down a bond that actually exists. "remove" on a merely
      # discovered device evicts it from the cache and the following "pair"
      # fails with "Device not available".
      if bluetoothctl info "$ADDR" 2>/dev/null | grep -q "Paired: yes"; then
        send "remove $ADDR"
        echo ">>> Removed stale bond, waiting for it to re-advertise..."
        for _ in $(seq 1 25); do
          if bluetoothctl info "$ADDR" 2>/dev/null | grep -q "Name:"; then break; fi
          sleep 1
        done
      fi
    fi

    send "pair $ADDR"
    sleep 12
    send "trust $ADDR"        # without this it will not auto-reconnect
    send "connect $ADDR"
    sleep 6
    send "quit"
    sleep 1

    echo ">>> Result:"
    bluetoothctl info "$ADDR" \
      | grep -iE "Name:|Paired:|Bonded:|Trusted:|Connected:" || true
    strip | grep -aiE "Pairing successful|Failed to pair|AuthenticationFailed|not available" \
      | tail -3 || true
  '';
}
