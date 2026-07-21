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
    initContent = ''
      export LS_COLORS="di=01;31:ln=31:ex=01;31:so=31:pi=31:bd=31:cd=31:or=01;31:mi=01;31:su=31:sg=31:tw=01;31:ow=01;31:st=31"
    '';
  };
}
