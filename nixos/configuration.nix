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
    chromium.enableWideVine = true;
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
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        # Framework exposes an ACPI platform_profile; let TLP push it low on
        # battery (fans/firmware back off further than EPP alone achieves).
        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "low-power";

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

    etc."vimrc".text = ''
      set number
      set relativenumber
      syntax on
      set mouse=a

      if exists('+termguicolors')
        set termguicolors
      endif
      set background=dark

      " Dark-redish colorscheme, matching the terminal/prompt palette
      " (#d75f5f primary, #af5f5f secondary, #875f5f dim, #ff5f5f pop).
      " A couple of warm accents (gold for literals, muted teal for
      " types/preproc) are kept so distinct syntax kinds stay readable.
      hi Normal       guifg=#aaaaaa guibg=#000000 ctermfg=248 ctermbg=0
      hi Comment      guifg=#875f5f ctermfg=95 cterm=italic gui=italic
      hi Constant     guifg=#d78700 ctermfg=172
      hi String       guifg=#d78700 ctermfg=172
      hi Number       guifg=#d78700 ctermfg=172
      hi Identifier   guifg=#af5f5f ctermfg=131
      hi Function     guifg=#af5f5f ctermfg=131 gui=bold cterm=bold
      hi Statement    guifg=#d75f5f ctermfg=167 gui=bold cterm=bold
      hi Keyword      guifg=#d75f5f ctermfg=167 gui=bold cterm=bold
      hi Conditional  guifg=#d75f5f ctermfg=167
      hi Repeat       guifg=#d75f5f ctermfg=167
      hi Operator     guifg=#d75f5f ctermfg=167
      hi PreProc      guifg=#5f8787 ctermfg=66
      hi Include      guifg=#5f8787 ctermfg=66
      hi Type         guifg=#5f8787 ctermfg=66
      hi StorageClass guifg=#5f8787 ctermfg=66
      hi Special      guifg=#d78700 ctermfg=172
      hi Delimiter    guifg=#af5f5f ctermfg=131
      hi Error        guifg=#ffffff guibg=#ff5f5f ctermfg=15 ctermbg=203 gui=bold cterm=bold
      hi Todo         guifg=#ff5f5f guibg=#000000 ctermfg=203 ctermbg=0 gui=bold cterm=bold
      hi LineNr       guifg=#875f5f ctermfg=95
      hi CursorLineNr guifg=#ff5f5f ctermfg=203 gui=bold cterm=bold
      hi CursorLine   guibg=#2a0000 ctermbg=52
      hi Visual       guibg=#5f0000 ctermbg=52
      hi Search       guifg=#000000 guibg=#d78700 ctermfg=0 ctermbg=172
      hi IncSearch    guifg=#000000 guibg=#ff5f5f ctermfg=0 ctermbg=203
      hi MatchParen   guifg=#ffffff guibg=#5f0000 ctermfg=15 ctermbg=52 gui=bold cterm=bold
      hi StatusLine   guifg=#000000 guibg=#af5f5f ctermfg=0 ctermbg=131
      hi StatusLineNC guifg=#875f5f guibg=#1a0000 ctermfg=95 ctermbg=0
      hi VertSplit    guifg=#5f0000 guibg=#5f0000 ctermfg=52 ctermbg=52
      hi Pmenu        guifg=#aaaaaa guibg=#2a0000 ctermfg=248 ctermbg=52
      hi PmenuSel     guifg=#000000 guibg=#d75f5f ctermfg=0 ctermbg=167

      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent

      set hlsearch
      set incsearch
      set clipboard=unnamedplus
      set noswapfile
    '';
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
