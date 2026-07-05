# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./wireless.nix
    ];
 
  programs._1password = { enable = true; };
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "ngerber" ];
  };
 
  programs.zsh.enable = true;

  # lanzaboote replaces systemd-boot to add Secure Boot signing of the
  # boot manager and every generation's kernel .efi image.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/3150b78f-729d-4e06-a4d8-b4cb2e271e93";
    preLVM = true;
  };
  boot.initrd.secrets = {
    "/boot/keys/zfs.key" = "/boot/keys/zfs.key";
  };
  boot.initrd.systemd.emergencyAccess = false;

  networking.hostName = "nix-frame"; # Define your hostname.
  networking.hostId = "d38345c2";
  # Wireless networking (wpa_supplicant, NetworkManager disabled) is configured
  # in ./wireless.nix.

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    enable = true;
    font = "ter-v32b";
    packages = with pkgs; [ terminus_font ];
    keyMap = "de";
  
    colors = [ 
      "282828" "cc241d" "98971a" "d79921" "458588" "b16286" "689d6a" "a89984"
      "928374" "fb4934" "b8bb26" "fabd2f" "83a598" "d3869b" "8ec07c" "ebdbb2"
    ];
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  services.xserver.windowManager.i3 = {
  enable = true;
  extraPackages = with pkgs; [
      rofi
      polybar
      picom
      feh
    ];
  };
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ngerber = {
    isNormalUser = true;
    description = "ngerber";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    alacritty
    chromium
    tree
    sbctl
    brightnessctl
  ];

  # brightnessctl ships a udev rule that chgrp/chmod's the backlight sysfs
  # file to group "video" on add; without registering the package here the
  # rule never runs and the file stays root-owned/read-only.
  services.udev.packages = [ pkgs.brightnessctl ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes" ];
}

# --- Parked idea: ZFS key from removable stick instead of baked into initrd ---
#
# Goal: read the ZFS native-encryption key from the removable BOOTKEY stick's
# /boot partition at boot time, instead of baking it into the initrd via
# boot.initrd.secrets above.
#
# What that required, from testing:
#   - fileSystems."/boot" needs neededForBoot = true, plus
#     options = [ "x-systemd.device-timeout=0" "x-systemd.requires=systemd-udev-settle.service" ]
#     to reliably wait for the slow-to-enumerate USB stick during stage 1.
#   - boot.initrd.systemd.services.systemd-udev-settle.enable = true;
#   - boot.initrd.kernelModules = [ "xhci_pci" "usb_storage" "sd_mod" ];
#     boot.initrd.availableKernelModules = [ "vfat" "nls_cp437" "nls_iso8859-1" ];
#   - boot.initrd.systemd.services.zfs-import-zroot needs both:
#       unitConfig.RequiresMountsFor = [ "/boot" ];
#       after = [ "cryptsetup.target" ]; requires = [ "cryptsetup.target" ];
#     zfs-import-zroot has no default ordering against the LUKS unlock, so
#     without this it can race ahead of cryptsetup and fail to find the pool.
#
# Even with all of the above, boot still failed at "Import ZFS pool zroot"
# after LUKS unlocked fine. Root cause not found; revisit later.
