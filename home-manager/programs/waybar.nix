{ ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;

        modules-left = [ "sway/workspaces" "sway/mode" ];

        "sway/workspaces" = {
          # false = each bar lists only the workspaces on its own output
          all-outputs = false;
          format = "{name}";
        };

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

      #workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: #a89984;
        border-bottom: 2px solid transparent;
      }

      #workspaces button.visible {
        color: #ebdbb2;
      }

      #workspaces button.focused {
        color: #ebdbb2;
        border-bottom: 2px solid #458588;
      }

      #workspaces button.urgent {
        color: #cc241d;
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
