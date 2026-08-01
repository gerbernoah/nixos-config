# Notes

## Parked: ZFS key from removable stick instead of baked into initrd

Goal: read the ZFS native-encryption key from the removable BOOTKEY stick's
`/boot` partition at boot time, instead of baking it into the initrd via
`boot.initrd.secrets` in `nixos/configuration.nix`.

What that required, from testing:

- `fileSystems."/boot"` needs `neededForBoot = true`, plus
  `options = [ "x-systemd.device-timeout=0" "x-systemd.requires=systemd-udev-settle.service" ]`
  to reliably wait for the slow-to-enumerate USB stick during stage 1.
- `boot.initrd.systemd.services.systemd-udev-settle.enable = true;`
- `boot.initrd.kernelModules = [ "xhci_pci" "usb_storage" "sd_mod" ];`
  `boot.initrd.availableKernelModules = [ "vfat" "nls_cp437" "nls_iso8859-1" ];`
- `boot.initrd.systemd.services.zfs-import-zroot` needs both:
  - `unitConfig.RequiresMountsFor = [ "/boot" ];`
  - `after = [ "cryptsetup.target" ]; requires = [ "cryptsetup.target" ];`

  `zfs-import-zroot` has no default ordering against the LUKS unlock, so without
  this it can race ahead of cryptsetup and fail to find the pool.

Even with all of the above, boot still failed at "Import ZFS pool zroot" after
LUKS unlocked fine. Root cause not found; revisit later.
