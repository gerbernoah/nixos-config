{ lib, pkgs, ... }:

let
  imageTypes = [
    "image/avif"
    "image/bmp"
    "image/gif"
    "image/heif"
    "image/jpeg"
    "image/jpg"
    "image/jxl"
    "image/pjpeg"
    "image/png"
    "image/qoi"
    "image/svg+xml"
    "image/tiff"
    "image/tiff-fx"
    "image/webp"
    "image/x-bmp"
    "image/x-farbfeld"
    "image/x-png"
  ];
in
{
  home.packages = [ pkgs.imv ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.genAttrs imageTypes (_: "imv.desktop") // {
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      "x-scheme-handler/jetbrains" = "jetbrainsd.desktop";
    };
  };
}
