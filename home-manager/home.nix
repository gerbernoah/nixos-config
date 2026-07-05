{ config, pkgs, inputs, ... }:

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
}
