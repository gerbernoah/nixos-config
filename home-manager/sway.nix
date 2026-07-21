{ pkgs, ... }:

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
  # Cursor theme for BOTH cursor paths:
  #  - sets XCURSOR_THEME/XCURSOR_SIZE in the session env (client-drawn cursors:
  #    Zed, JetBrains) — this is what makes their drag cursor resolve at all;
  #  - configures GTK.
  # The sway `seat` line below covers the compositor-drawn path (cursor-shape-v1:
  # Chromium, Alacritty). Note: client-drawn apps use a fixed pixel size and
  # ignore per-output scale, so they render ~24px on every monitor.
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
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
        # Hi-DPI laptop panel needs upscaling; the 1.0 default is only right for externals.
        "eDP-2" = {
          position = "0 0";
          scale = "1.5";
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
      seat "*" xcursor_theme Adwaita 24
      tiling_drag enable
      exec swayidle -w \
        timeout 300 'swaylock -f' \
        before-sleep 'swaylock -f'
    '';
  };
}
