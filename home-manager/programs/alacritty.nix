{ config, lib, pkgs, ... }:

let
  configDir = "${config.home.homeDirectory}/.config/alacritty";

  activeTheme = "${configDir}/theme.toml";
  themesDir = "${configDir}/themes";

  defaultTheme = "ember";

  themes = {
    ember = {
      primary = { background = "#000000"; foreground = "#e8dfd4"; };
      cursor = { text = "#000000"; cursor = "#e8dfd4"; };
      normal = {
        black = "#000000";
        red = "#c62828";
        green = "#af5f00";
        yellow = "#af8700";
        blue = "#9a5050"; 
        magenta = "#c0006a"; 
        cyan = "#875f5f";
        white = "#e8dfd4";
      };
      bright = {
        black = "#6e6e6e";
        red = "#ff5f5f";
        green = "#d78700";
        yellow = "#ffaf5f";
        blue = "#af5f5f";
        magenta = "#ff5faf";
        cyan = "#d75f5f";
        white = "#ffffff";
      };
    };

    gruvbox-dark = {
      primary = { background = "#282828"; foreground = "#ebdbb2"; };
      cursor = { text = "#282828"; cursor = "#ebdbb2"; };
      normal = {
        black = "#282828";
        red = "#cc241d";
        green = "#98971a";
        yellow = "#d79921";
        blue = "#458588";
        magenta = "#b16286";
        cyan = "#689d6a";
        white = "#a89984";
      };
      bright = {
        black = "#928374";
        red = "#fb4934";
        green = "#b8bb26";
        yellow = "#fabd2f";
        blue = "#83a598";
        magenta = "#d3869b";
        cyan = "#8ec07c";
        white = "#ebdbb2";
      };
    };

    nord = {
      primary = { background = "#2e3440"; foreground = "#d8dee9"; };
      cursor = { text = "#2e3440"; cursor = "#d8dee9"; };
      normal = {
        black = "#3b4252";
        red = "#bf616a";
        green = "#a3be8c";
        yellow = "#ebcb8b";
        blue = "#81a1c1";
        magenta = "#b48ead";
        cyan = "#88c0d0";
        white = "#e5e9f0";
      };
      bright = {
        black = "#4c566a";
        red = "#bf616a";
        green = "#a3be8c";
        yellow = "#ebcb8b";
        blue = "#81a1c1";
        magenta = "#b48ead";
        cyan = "#8fbcbb";
        white = "#eceff4";
      };
    };

    tokyo-night = {
      primary = { background = "#1a1b26"; foreground = "#c0caf5"; };
      cursor = { text = "#1a1b26"; cursor = "#c0caf5"; };
      normal = {
        black = "#15161e";
        red = "#f7768e";
        green = "#9ece6a";
        yellow = "#e0af68";
        blue = "#7aa2f7";
        magenta = "#bb9af7";
        cyan = "#7dcfff";
        white = "#a9b1d6";
      };
      bright = {
        black = "#414868";
        red = "#f7768e";
        green = "#9ece6a";
        yellow = "#e0af68";
        blue = "#7aa2f7";
        magenta = "#bb9af7";
        cyan = "#7dcfff";
        white = "#c0caf5";
      };
    };

    solarized-light = {
      primary = { background = "#fdf6e3"; foreground = "#586e75"; };
      cursor = { text = "#fdf6e3"; cursor = "#586e75"; };
      normal = {
        black = "#073642";
        red = "#dc322f";
        green = "#6f8000";
        yellow = "#96720a";
        blue = "#268bd2";
        magenta = "#d33682";
        cyan = "#22867f"; 
        white = "#657b83";
      };
      bright = {
        black = "#002b36";
        red = "#cb4b16";
        green = "#586e75";
        yellow = "#657b83";
        blue = "#5b7076";
        magenta = "#6c71c4";
        cyan = "#6e8080";
        white = "#073642";
      };
    };
  };

  tomlFormat = pkgs.formats.toml { };

  themeFiles = lib.mapAttrs' (name: colors:
    lib.nameValuePair ".config/alacritty/themes/${name}.toml" {
      source = tomlFormat.generate "alacritty-theme-${name}.toml" { inherit colors; };
    }) themes;

  themeNames = lib.attrNames themes;

  themeSwitcher = pkgs.writeShellApplication {
    name = "alacritty-theme";
    runtimeInputs = [ pkgs.fzf pkgs.libnotify config.programs.alacritty.package ];
    text = ''
      themes_dir=${lib.escapeShellArg themesDir}
      active=${lib.escapeShellArg activeTheme}
      known=(${lib.escapeShellArgs themeNames})
      self="''${BASH_SOURCE[0]}"

      usage() {
        printf 'usage: alacritty-theme [<name>|--list|--current]\n\navailable:\n' >&2
        printf '  %s\n' "''${known[@]}" >&2
      }

      apply() {
        local src tmp
        src="$themes_dir/$1.toml"
        [ -f "$src" ] || return 1
        tmp="$(mktemp "$active.XXXXXX")"
        cat "$src" > "$tmp"
        chmod 0644 "$tmp"
        mv -f "$tmp" "$active"
      }

      current() {
        local name
        for name in "''${known[@]}"; do
          if cmp -s "$active" "$themes_dir/$name.toml"; then
            echo "$name"
            return 0
          fi
        done
        return 1
      }

      pick() {
        local prev choice
        prev="$(current || true)"
        if choice="$(printf '%s\n' "''${known[@]}" \
              | fzf --layout=reverse --height=100% --info=inline \
                    --prompt='theme> ' \
                    --header='enter = keep, esc = revert' \
                    --bind="focus:execute-silent($self --apply {})")"; then
          apply "$choice"
        elif [ -n "$prev" ]; then
          apply "$prev"
        fi
      }

      case "''${1-}" in
        --list|-l)
          printf '%s\n' "''${known[@]}"
          ;;
        --current|-c)
          current || { echo "unknown" >&2; exit 1; }
          ;;
        --apply)
          apply "''${2-}" || exit 1
          ;;
        --pick)
          pick
          ;;
        -h|--help)
          usage
          ;;
        "")
          if [ -t 0 ] && [ -t 1 ]; then
            pick
          else
            exec alacritty --title alacritty-theme-picker -e "$self" --pick
          fi
          ;;
        *)
          if ! apply "$1"; then
            printf 'alacritty-theme: unknown theme %s\n' "$1" >&2
            usage
            exit 1
          fi
          notify-send -t 2000 "alacritty" "theme: $1" 2>/dev/null || true
          ;;
      esac
    '';
  };
in
{
  home = {
    packages = [ themeSwitcher ];

    file = themeFiles;

    activation.alacrittyTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e ${lib.escapeShellArg activeTheme} ]; then
        run cp $VERBOSE_ARG \
          ${tomlFormat.generate "alacritty-theme-${defaultTheme}.toml" { colors = themes.${defaultTheme}; }} \
          ${lib.escapeShellArg activeTheme}
        run chmod $VERBOSE_ARG u+w ${lib.escapeShellArg activeTheme}
      fi
    '';
  };

  wayland.windowManager.sway = {
    config.keybindings."Mod4+t" = "exec ${themeSwitcher}/bin/alacritty-theme";

    extraConfig = ''
      for_window [title="^alacritty-theme-picker$"] floating enable, resize set 520 320
    '';
  };

  programs.alacritty = {
    enable = true;
    settings = {
      general = {
        import = [ activeTheme ];
        live_config_reload = true;
      };

      font.size = 14.0;

      keyboard.bindings = [
        {
          key = "Return";
          mods = "Shift";
          chars = builtins.fromJSON ''"\u001B\r"'';
        }
      ];
    };
  };
}
