{ config, pkgs, inputs, ... }:

{
  imports = [
    ./sway.nix
    ./programs/zed.nix
    ./programs/chromium.nix
    ./programs/direnv.nix
    ./programs/zsh.nix
    ./programs/alacritty.nix
    ./programs/starship.nix
    ./programs/waybar.nix
  ];

  home = {
    username = "ngerber";
    homeDirectory = "/home/ngerber";
    # Bump this only when you've read the release notes for the new value.
    stateVersion = "24.05";
    

    packages = with pkgs; [
      git
      fuzzel # app launcher / menu bound to Mod+d (sway menu = "fuzzel")
      nixd # Nix language server (editor completion/go-to-def)
      alejandra # Nix formatter
      statix # Nix linter
      deadnix # finds unused Nix bindings
      inputs.claude-desktop.packages.${pkgs.system}.claude-desktop
      jetbrains.idea
      docker-compose
      solaar # Logitech HID++ config (MX Master 4 DPI); needs the udev rules from the NixOS config
      pavucontrol # GUI audio mixer / output-device picker (PipeWire compatible)
    ];

    file.".vimrc".source = ./vimrc;
  };

  programs.home-manager.enable = true;
}
