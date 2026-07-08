{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    consoleLogLevel = 3;
    kernelParams = [ "quiet" ];
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;

    extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="JP"
    '';

    initrd = {
      kernelModules = [ "amdgpu" ];
      systemd.emergencyAccess = false;

      secrets = {
        "/boot/keys/zfs.key" = "/boot/keys/zfs.key";
      };

      luks.devices."cryptroot" = {
        device = "/dev/disk/by-uuid/3150b78f-729d-4e06-a4d8-b4cb2e271e93";
        preLVM = true;
      };
    };

    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  hardware = {
    wirelessRegulatoryDatabase = true;
    graphics.enable = true;
    enableRedistributableFirmware = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  programs = {
    nix-ld.enable = true;
    zsh.enable = true;
    sway.enable = true;
    vim.enable = true;

    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "ngerber" ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  networking = {
    hostName = "nix-frame";
    hostId = "d38345c2";

    networkmanager = {
      enable = true;
      wifi.macAddress = "stable";
    };
  };

  time.timeZone = "Europe/Zurich";
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

  services = {
    fwupd.enable = true;

    # TLP handles CPU EPP, PCIe ASPM, USB/SATA autosuspend etc. per AC/battery
    # state. Must be paired with power-profiles-daemon disabled below - the
    # two conflict over who owns CPU power policy.
    tlp = {
      enable = true;
      settings = {
        # amd-pstate is in "active" mode (confirmed via
        # /sys/devices/system/cpu/amd_pstate/status); EPP does the real work,
        # so keep the governor on powersave and drive behavior via EPP.
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;

        # Framework exposes an ACPI platform_profile; keep it "balanced" on
        # battery too - "low-power" capped clocks to ~1.4GHz, too aggressive.
        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "balanced";

        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";

        USB_AUTOSUSPEND = 1;

        SATA_LINKPWR_ON_AC = "med_power_with_dipm";
        SATA_LINKPWR_ON_BAT = "min_power";

        RUNTIME_PM_ON_AC = "auto";
        RUNTIME_PM_ON_BAT = "auto";
      };
    };

    power-profiles-daemon.enable = lib.mkForce false;

    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
    };

    xserver = {
      enable = true;
      xkb = {
        layout = "de";
        options = "eurosign:e,caps:escape";
      };
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    blueman.enable = true;

    libinput.enable = true;

    udev.packages = [ pkgs.brightnessctl ];
  };

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      wget
      tree
      sbctl
      brightnessctl
    ];
  };

  users.users.ngerber = {
    isNormalUser = true;
    description = "ngerber";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "docker"
    ];
  };

  system = {
    stateVersion = "24.05"; 
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
