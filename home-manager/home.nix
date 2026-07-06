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
  home.username = "ngerber";
  home.homeDirectory = "/home/ngerber";
  # Bump this only when you've read the release notes for the new value.
  home.stateVersion = "24.05";

  # Lets home-manager manage itself (adds the `home-manager` command).
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    git
    nixd # Nix language server (editor completion/go-to-def)
    alejandra # Nix formatter
    statix # Nix linter
    deadnix # finds unused Nix bindings
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      claude = "nix run github:ryoppippi/nix-claude-code#claude-fhs";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$directory$git_branch$git_commit$git_state$git_metrics$git_status$cmd_duration$line_break$jobs$time$battery$character";
      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%H:%M";
      };
      battery = {
        full_symbol = "=";
        charging_symbol = "^";
        discharging_symbol = "v";
        unknown_symbol = "?";
        empty_symbol = "x";
        display = [
          { threshold = 100; style = "bold green"; }
        ];
      };
    };
  };

  # sway itself is enabled at the system level (programs.sway in
  # configuration.nix); this only takes over generating
  # ~/.config/sway/config.
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = {
      modifier = mod;
      terminal = "alacritty";
      menu = "fuzzel";
      focus.wrapping = "no";

      # waybar is used instead of the built-in sway bar
      bars = [ ];

      startup = [
        { command = "dex --autostart --environment sway"; }
        { command = "nm-applet --indicator"; }
        { command = "1password --silent"; }
      ];

      keybindings = defaultSwayKeybindings // {
        # vim-style focus/move, true hjkl orientation. Overrides the default
        # mod+h (split h) and mod+v (split v), which move to mod+n/mod+m below.
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

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 28;

        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];

        "sway/workspaces" = {
          disable-scroll = true;
        };

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
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: #282828;
        color: #ebdbb2;
      }

      #workspaces button {
        padding: 0 8px;
        color: #ebdbb2;
      }

      #workspaces button.focused {
        background-color: #458588;
        color: #282828;
      }

      #workspaces button.urgent {
        background-color: #cc241d;
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
}
