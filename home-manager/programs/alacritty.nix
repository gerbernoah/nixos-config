{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      font.size = 14.0;

      colors = {
        primary = {
          background = "#000000";
          foreground = "#e8dfd4";
        };
        cursor = {
          text = "#000000";
          cursor = "#e8dfd4";
        };
        normal = {
          black = "#000000";
          red = "#aa0000";
          green = "#af5f00";
          yellow = "#af8700";
          blue = "#5f0000";
          magenta = "#af005f";
          cyan = "#875f5f";
          white = "#e8dfd4";
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
}
