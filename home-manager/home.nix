{ config, pkgs, inputs, ... }:

{
  imports = [
    ./zed.nix
    ./sway.nix
  ];

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
      pavucontrol # GUI audio mixer / output-device picker (PipeWire compatible)
    ];

    file.".vimrc".source = ./vimrc;
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
      # Core video decoding/encoding and modern canvas rendering features.
      # Vulkan/ANGLE-Vulkan removed: Chromium rejects them under --ozone-platform=wayland
      # ("not compatible with Vulkan") and falls back, so they only added error spam.
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
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
        bun = "nix run nixpkgs#bun --";
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
}
