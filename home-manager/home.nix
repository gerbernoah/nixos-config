{ config, pkgs, inputs, ... }:

{
  imports = [
    ./sway.nix
    ./programs/ssh.nix
    ./programs/zed.nix
    ./programs/chromium.nix
    ./programs/direnv.nix
    ./programs/imv.nix
    ./programs/zsh.nix
    ./programs/alacritty.nix
    ./programs/starship.nix
    ./programs/waybar.nix
  ];

  home = {
    username = "ngerber";
    homeDirectory = "/home/ngerber";
    stateVersion = "24.05";

    packages = with pkgs; [
      git
      fuzzel
      nixd
      alejandra
      statix
      deadnix
      inputs.claude-desktop.packages.${pkgs.system}.claude-desktop
      jetbrains.idea
      docker-compose
      solaar
      pavucontrol
      tor-browser
      obsidian
    ];

    file.".vimrc".source = ./vimrc;
  };

  programs.home-manager.enable = true;
}
