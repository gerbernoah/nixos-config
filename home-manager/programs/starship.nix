{ ... }:
{
  programs.starship = {
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
}
