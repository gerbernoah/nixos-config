{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableWideVine = true;
    };

    extensions = [
      "ghmbeldphafepmbegfdlkpapadhbakde" # Proton Pass
    ];

    commandLineArgs = [
      "--ozone-platform-hint=wayland"
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
      "--ignore-gpu-blocklist"
      "--enable-zero-copy"
    ];
  };
}
