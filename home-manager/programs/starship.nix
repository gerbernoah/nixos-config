{ ... }:
{
  # Every style here names an ANSI palette slot rather than a hex value, so the
  # prompt follows whatever alacritty theme is loaded (see programs/alacritty.nix).
  # Hex styles emit truecolor escapes, which bypass the palette and stay fixed no
  # matter what the terminal is themed to.
  #
  # The slots chosen are the ones the old hardcoded hexes occupied in the "ember"
  # palette, so under ember the prompt looks exactly as it did before:
  #   bright-cyan #d75f5f · bright-blue #af5f5f · cyan #875f5f · bright-red #ff5f5f
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$directory$git_branch$git_commit$git_state$git_metrics$git_status$cmd_duration$line_break$jobs$time$battery$character";

      directory.style = "bold bright-cyan";

      git_branch.style = "bright-blue";
      git_commit.style = "cyan";
      git_state.style = "bright-blue";
      git_status.style = "bold bright-red";
      git_metrics = {
        added_style = "bright-blue";
        deleted_style = "bold bright-cyan";
      };

      cmd_duration.style = "cyan";

      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%H:%M";
        style = "bright-blue";
      };

      battery = {
        full_symbol = "=";
        charging_symbol = "^";
        discharging_symbol = "v";
        unknown_symbol = "?";
        empty_symbol = "x";
        display = [
          { threshold = 20; style = "bold bright-red"; }
          { threshold = 100; style = "bright-blue"; }
        ];
      };

      character = {
        success_symbol = "[❯](bright-cyan)";
        error_symbol = "[❯](bold bright-red)";
      };
    };
  };
}
