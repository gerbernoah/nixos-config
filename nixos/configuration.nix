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
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    enableRedistributableFirmware = true;

    i2c.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  programs = {
    nix-ld.enable = true;
    zsh.enable = true;
    sway = {
      enable = true;
      extraPackages = with pkgs; [ swaylock swayidle ];
    };
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
    keyMap = "us";

    colors = [
      "282828" "cc241d" "98971a" "d79921" "458588" "b16286" "689d6a" "a89984"
      "928374" "fb4934" "b8bb26" "fabd2f" "83a598" "d3869b" "8ec07c" "ebdbb2"
    ];
  };

  services = {
    fwupd.enable = true;

    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;

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
        layout = "us";
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

  hardware.logitech.wireless.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw*", KERNELS=="0005:046D:*", MODE="0660", GROUP="users", TAG+="uaccess"
    KERNEL=="hidraw*", KERNELS=="0003:19F5:*", MODE="0660", GROUP="users", TAG+="uaccess"
    KERNEL=="hidraw*", KERNELS=="0005:19F5:*", MODE="0660", GROUP="users", TAG+="uaccess"
  '';

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      wget
      tree
      sbctl
      brightnessctl
      ddcutil
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
      "i2c"
    ];
  };

  system = {
    stateVersion = "24.05";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
