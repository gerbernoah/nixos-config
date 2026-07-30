{ config, lib, pkgs, ... }:

let
  configDir = "${config.home.homeDirectory}/.config/alacritty";

  # Alacritty re-reads its config (and every file it imports) on write, so
  # hot-swapping a theme is just "rewrite the imported file". theme.toml is
  # deliberately NOT managed by home-manager — HM-managed files are read-only
  # symlinks into the nix store, and the switcher has to be able to overwrite it.
  activeTheme = "${configDir}/theme.toml";
  themesDir = "${configDir}/themes";

  # The theme that gets seeded on first switch, and the fallback if theme.toml
  # is ever deleted.
  defaultTheme = "ember";

  # Each theme is a complete `colors` table: an import only merges, it doesn't
  # reset, so a theme that omitted e.g. `bright` would inherit the previous
  # theme's bright colors on reload.
  #
  # Nothing outside this file hardcodes a colour — the prompt, ls, and TUI apps
  # all address the 16 palette slots by name/index, so they follow whatever is
  # loaded here. That only works if every slot is legible against its own
  # background, so slots below ~3:1 contrast have been lifted. gruvbox, nord and
  # tokyo-night are otherwise untouched upstream palettes; where their hues look
  # "wrong" (gruvbox's blue really is a teal) that is the palette's own design.
  themes = {
    # The hand-rolled dark red/amber palette this config used before themes
    # were split out. Deliberately monochrome — "blue" and "cyan" are warm here,
    # which is the theme's identity, not a mistake. Slots that were too dark to
    # read on black have been lifted (see the contrast note at the top of the
    # themes block); everything is now >= 3:1 against the background.
    ember = {
      primary = { background = "#000000"; foreground = "#e8dfd4"; };
      cursor = { text = "#000000"; cursor = "#e8dfd4"; };
      normal = {
        black = "#000000";
        red = "#c62828"; # was #aa0000 (2.7:1)
        green = "#af5f00";
        yellow = "#af8700";
        blue = "#9a5050"; # was #5f0000 (1.5:1) — unreadable, and ls paints dirs with it
        magenta = "#c0006a"; # was #af005f (3.0:1)
        cyan = "#875f5f";
        white = "#e8dfd4";
      };
      bright = {
        black = "#6e6e6e"; # was #555555 (2.8:1) — common "dim text" slot
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

    # The one light theme in the set — handy outdoors / on a projector.
    #
    # Canonical Solarized Light is unusable as a terminal palette: it reuses the
    # white slots for its *background* tones (white = #eee8d5, bright-white =
    # #fdf6e3, i.e. the background itself) and parks two mid-greys in
    # bright-blue/bright-cyan. Any program that prints white or "dim grey" text
    # — which is most TUIs, Claude Code included — then draws it invisibly.
    #
    # So the grey ramp is inverted for a light background: on light, "brighter"
    # has to mean *darker* to stay legible. Hues are stock Solarized; only the
    # lightness of the offending slots changed.
    solarized-light = {
      primary = { background = "#fdf6e3"; foreground = "#586e75"; };
      cursor = { text = "#fdf6e3"; cursor = "#586e75"; };
      normal = {
        black = "#073642";
        red = "#dc322f";
        green = "#6f8000"; # was #859900 (3.0:1)
        yellow = "#96720a"; # was #b58900 (3.0:1)
        blue = "#268bd2";
        magenta = "#d33682";
        cyan = "#22867f"; # was #2aa198 (2.9:1)
        white = "#657b83"; # was #eee8d5 — 1.1:1, near-invisible as text
      };
      bright = {
        black = "#002b36";
        red = "#cb4b16";
        green = "#586e75";
        yellow = "#657b83";
        blue = "#5b7076"; # was #839496 (2.9:1) — the washed-out "dim text" grey
        magenta = "#6c71c4";
        cyan = "#6e8080"; # was #93a1a1 (2.5:1)
        white = "#073642"; # was #fdf6e3 — literally the background (1.0:1)
      };
    };
  };

  tomlFormat = pkgs.formats.toml { };

  # themes/<name>.toml, one store file per theme, symlinked read-only.
  themeFiles = lib.mapAttrs' (name: colors:
    lib.nameValuePair ".config/alacritty/themes/${name}.toml" {
      source = tomlFormat.generate "alacritty-theme-${name}.toml" { inherit colors; };
    }) themes;

  themeNames = lib.attrNames themes;

  # `alacritty-theme` with no args opens a picker that applies each theme as you
  # move through the list; with a name it swaps directly.
  #
  # The picker is fzf rather than fuzzel because previewing needs a hook that
  # fires on *highlight*, not on accept — fuzzel's dmenu mode only ever prints
  # the accepted line, while fzf's `focus` event fires per selection change.
  # Running it in a terminal is also the honest preview surface: you see the
  # palette on real terminal output rather than on a launcher's own widgets.
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
        # Write-then-rename so alacritty never observes a half-written import.
        tmp="$(mktemp "$active.XXXXXX")"
        cat "$src" > "$tmp"
        chmod 0644 "$tmp" # mktemp gives 0600; keep theme.toml matching the seeded copy
        mv -f "$tmp" "$active"
      }

      current() {
        # theme.toml is a plain copy, not a symlink, so identify it by content.
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
        # Every highlight change re-writes theme.toml; alacritty's live reload
        # repaints this window under the picker. Esc puts back what you started on.
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
          # Internal: the picker's per-highlight hook. Silent, no notification.
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
            # Launched from a keybinding, so there's no terminal to preview in
            # — open one. The sway rule below floats it.
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

    # Seed theme.toml on first switch (and restore it if it gets deleted). Never
    # overwrites an existing choice, so switching generations doesn't reset the
    # theme you're currently on.
    activation.alacrittyTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e ${lib.escapeShellArg activeTheme} ]; then
        run cp $VERBOSE_ARG \
          ${tomlFormat.generate "alacritty-theme-${defaultTheme}.toml" { colors = themes.${defaultTheme}; }} \
          ${lib.escapeShellArg activeTheme}
        run chmod $VERBOSE_ARG u+w ${lib.escapeShellArg activeTheme}
      fi
    '';
  };

  # Mod+t opens the picker. Declared here rather than in sway.nix so the whole
  # theming feature stays in one file — `keybindings` is an attrsOf option, so
  # definitions from separate modules merge.
  wayland.windowManager.sway = {
    config.keybindings."Mod4+t" = "exec ${themeSwitcher}/bin/alacritty-theme";

    # Float the picker window so it reads as a dialog, and so the tiled windows
    # behind it stay visible while their colors change.
    extraConfig = ''
      for_window [title="^alacritty-theme-picker$"] floating enable, resize set 520 320
    '';
  };

  programs.alacritty = {
    enable = true;
    settings = {
      general = {
        # Imports are applied first and the importing file wins, so nothing
        # here may set `colors` — it would shadow the theme.
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
