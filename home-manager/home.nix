{ config, pkgs, inputs, ... }:

let
  mod = "Mod4";

  defaultSwayKeybindings = {
    "${mod}+Return" = "exec alacritty";
    "${mod}+Shift+q" = "kill";
    "${mod}+d" = "exec fuzzel";

    "${mod}+Left" = "focus left";
    "${mod}+Down" = "focus down";
    "${mod}+Up" = "focus up";
    "${mod}+Right" = "focus right";

    "${mod}+Shift+Left" = "move left";
    "${mod}+Shift+Down" = "move down";
    "${mod}+Shift+Up" = "move up";
    "${mod}+Shift+Right" = "move right";

    "${mod}+h" = "split h";
    "${mod}+v" = "split v";
    "${mod}+f" = "fullscreen toggle";

    "${mod}+s" = "layout stacking";
    "${mod}+w" = "layout tabbed";
    "${mod}+e" = "layout toggle split";

    "${mod}+Shift+space" = "floating toggle";
    "${mod}+space" = "focus mode_toggle";

    "${mod}+a" = "focus parent";

    "${mod}+Shift+minus" = "move scratchpad";
    "${mod}+minus" = "scratchpad show";

    "${mod}+1" = "workspace number 1";
    "${mod}+2" = "workspace number 2";
    "${mod}+3" = "workspace number 3";
    "${mod}+4" = "workspace number 4";
    "${mod}+5" = "workspace number 5";
    "${mod}+6" = "workspace number 6";
    "${mod}+7" = "workspace number 7";
    "${mod}+8" = "workspace number 8";
    "${mod}+9" = "workspace number 9";
    "${mod}+0" = "workspace number 10";

    "${mod}+Shift+1" = "move container to workspace number 1";
    "${mod}+Shift+2" = "move container to workspace number 2";
    "${mod}+Shift+3" = "move container to workspace number 3";
    "${mod}+Shift+4" = "move container to workspace number 4";
    "${mod}+Shift+5" = "move container to workspace number 5";
    "${mod}+Shift+6" = "move container to workspace number 6";
    "${mod}+Shift+7" = "move container to workspace number 7";
    "${mod}+Shift+8" = "move container to workspace number 8";
    "${mod}+Shift+9" = "move container to workspace number 9";
    "${mod}+Shift+0" = "move container to workspace number 10";

    "${mod}+Shift+c" = "reload";
    "${mod}+Shift+r" = "restart";
    "${mod}+Shift+e" =
      "exec swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes' 'swaymsg exit'";

    "${mod}+r" = "mode resize";
  };
in
{
  home = {
    username = "ngerber";
    homeDirectory = "/home/ngerber";
    # Bump this only when you've read the release notes for the new value.
    stateVersion = "24.05";
    

    packages = with pkgs; [
      git
      fuzzel # app launcher / menu bound to Mod+d (sway menu = "fuzzel")
      nixd # Nix language server (editor completion/go-to-def)
      alejandra # Nix formatter
      statix # Nix linter
      deadnix # finds unused Nix bindings
      inputs.claude-desktop.packages.${pkgs.system}.claude-desktop
      jetbrains.idea
      docker-compose
      solaar # Logitech HID++ config (MX Master 4 DPI); needs the udev rules from the NixOS config
    ];

    file.".vimrc".text = ''
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


  programs = {
    home-manager.enable = true;

    chromium = {
      enable = true;
      package = pkgs.chromium.override {
        enableWideVine = true;
      };

      extensions = [
        "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
      ];

      commandLineArgs = [
      # Forces Chromium to use native Wayland instead of XWayland
      "--ozone-platform-hint=wayland"
      # Core video decoding/encoding and modern canvas rendering features
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
      # Bypasses Chromium's overly restrictive Linux GPU safety blocks
      "--ignore-gpu-blocklist"
      # Dramatically reduces CPU overhead by drawing straight to the GPU
      "--enable-zero-copy"
    ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        claude = "nix run github:ryoppippi/nix-claude-code#claude-fhs";
        lock = "swaylock -f -c 000000 --ignore-empty-password --show-failed-attempts";
      };
      initContent = ''
        export LS_COLORS="di=01;31:ln=31:ex=01;31:so=31:pi=31:bd=31:cd=31:or=01;31:mi=01;31:su=31:sg=31:tw=01;31:ow=01;31:st=31"
      '';
    };

    alacritty = {
      enable = true;
      settings = {
        font.size = 14.0;

        colors = {
          primary = {
            background = "#000000";
            foreground = "#aaaaaa";
          };
          cursor = {
            text = "#000000";
            cursor = "#aaaaaa";
          };
          normal = {
            black = "#000000";
            red = "#aa0000";
            green = "#af5f00";
            yellow = "#af8700";
            blue = "#5f0000";
            magenta = "#af005f";
            cyan = "#875f5f";
            white = "#aaaaaa";
          };
          bright = {
            black = "#555555";
            red = "#ff5f5f";
            green = "#d78700";
            yellow = "#ffaf5f";
            blue = "#af5f5f";
            magenta = "#ff5faf";
            cyan = "#d75f5f";
            white = "#ffffff";
          };
        };

        keyboard.bindings = [
          {
            key = "Return";
            mods = "Shift";
            chars = builtins.fromJSON ''"\u001B\r"'';
          }
        ];
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = "$directory$git_branch$git_commit$git_state$git_metrics$git_status$cmd_duration$line_break$jobs$time$battery$character";

        directory.style = "bold #d75f5f";

        git_branch.style = "#af5f5f";
        git_commit.style = "#875f5f";
        git_state.style = "#af5f5f";
        git_status.style = "bold #ff5f5f";
        git_metrics = {
          added_style = "#af5f5f";
          deleted_style = "bold #d75f5f";
        };

        cmd_duration.style = "#875f5f";

        time = {
          disabled = false;
          format = "[$time]($style) ";
          time_format = "%H:%M";
          style = "#af5f5f";
        };

        battery = {
          full_symbol = "=";
          charging_symbol = "^";
          discharging_symbol = "v";
          unknown_symbol = "?";
          empty_symbol = "x";
          display = [
            { threshold = 20; style = "bold #ff5f5f"; }
            { threshold = 100; style = "#af5f5f"; }
          ];
        };

        character = {
          success_symbol = "[❯](#d75f5f)";
          error_symbol = "[❯](bold #ff5f5f)";
        };
      };
    };

    waybar = {
      enable = true;
      systemd.enable = false;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 32;

          modules-left = [ "sway/mode" ];
          modules-center = [ "clock" ];
          modules-right = [ "pulseaudio" "network" "battery" "tray" ];

          clock = {
            format = "{:%H:%M}";
          };

          battery = {
            format = "{capacity}% {icon}";
            format-icons = [ "" "" "" "" "" ];
            states = {
              warning = 30;
              critical = 15;
            };
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%)";
            format-ethernet = "eth";
            format-disconnected = "disconnected";
          };

          pulseaudio = {
            format = "{volume}% {icon}";
            format-muted = "muted";
            format-icons = {
              default = [ "" "" "" ];
            };
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };

          tray = {
            spacing = 8;
          };
        };
      };

      style = ''
        * {
          font-family: monospace;
          font-size: 14px;
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        window#waybar {
          background-color: #282828;
          color: #ebdbb2;
        }

        #clock,
        #pulseaudio,
        #network,
        #battery,
        #tray,
        #mode {
          padding: 0 10px;
        }

        #battery.warning {
          color: #d79921;
        }

        #battery.critical {
          color: #cc241d;
        }

        #mode {
          background-color: #d79921;
          color: #282828;
        }
      '';
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    package = null;

    config = {
      modifier = mod;
      terminal = "alacritty";
      menu = "fuzzel";
      focus.wrapping = "no";
      
      input = {
        "*".xkb_layout = "de";
        "type:touchpad".tap = "enabled";
      };
      output = {
        "*" = {
          scale = "1.0"; # default: native scaling for external/low-density panels
        };
        # Laptop on the left (anchor), external HP monitor on the right — matches physical layout.
        # Identify the external by make/model/serial so it works on any port.
        # It's a low-density 27" 1920x1200 panel, so scale 1.0 (native) instead of the
        # laptop's 1.5 — keeps UI size and pointer speed roughly consistent across screens.
        # eDP-2 logical width = 2560 / 1.5 = 1706, so the external starts at x=1706.
        "eDP-2" = {
          position = "0 0";
          scale = "1.5"; # hi-DPI laptop panel needs upscaling; the 1.0 default is only right for externals
        };
        "HP Inc. HP 527pq VNG5120026" = {
          position = "1706 0";
          scale = "1.0";
        };
      };

      window = {
        titlebar = false;
        border = 2;
      };
      floating = {
        titlebar = false;
        border = 2;
      };

      colors.focused = {
        border = "#ff0000";
        childBorder = "#ff0000";
        background = "#ff0000";
        text = "#ffffff";
        indicator = "#ff0000";
      };

      bars = [ ];

      startup = [
        { command = "dex --autostart --environment sway"; }
        { command = "solaar --window=hide"; } # background daemon: reapplies MX Master 4 DPI on connect
        { command = "nm-applet --indicator"; }
        { command = "1password --silent"; }
        { command = "waybar"; }
      ];

      keybindings = defaultSwayKeybindings // {
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+n" = "split h";
        "${mod}+m" = "split v";
        "${mod}+v" = null;

        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
      };
    };

    extraConfig = ''
      tiling_drag enable
      exec swayidle -w \
        timeout 300 'swaylock -f' \
        before-sleep 'swaylock -f'
    '';
  };
}
