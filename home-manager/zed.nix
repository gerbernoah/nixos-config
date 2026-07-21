{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
    nixfmt-rfc-style
    vtsls
    vscode-langservers-extracted
    prettier
  ];

  programs.zed-editor = {
    enable = true;

    extensions = [ "nix" "html" ];

    userSettings = {
      lsp = {
        nil.binary.path = "${pkgs.nil}/bin/nil";
        vtsls.binary.path = "${pkgs.vtsls}/bin/vtsls";
        eslint.binary.path = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
      };

      languages = {
        Nix = {
          language_servers = [ "nil" ];
          formatter.external = {
            command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
            arguments = [ "-" ];
          };
        };
        TypeScript = {
          language_servers = [ "vtsls" "eslint" ];
          formatter = "prettier";
        };
        TSX = {
          language_servers = [ "vtsls" "eslint" ];
          formatter = "prettier";
        };
        JavaScript = {
          language_servers = [ "vtsls" "eslint" ];
          formatter = "prettier";
        };
      };

      format_on_save = "on";

      telemetry = {
        metrics = false;
        diagnostics = false;
      };
    };
  };
}
