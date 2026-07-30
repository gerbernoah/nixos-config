{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      claude = "nix run github:ryoppippi/nix-claude-code#claude-fhs";
      bun = "nix run nixpkgs#bun --";
      lock = "swaylock -f -c 000000 --ignore-empty-password --show-failed-attempts";
    };
  };
}
