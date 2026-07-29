{ lib, pkgs, ... }:

let
  # Exactly the types imv.desktop declares — keep in sync if imv gains formats.
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
  # Wayland-native image viewer. Without it the only registered image handler was
  # Chromium, which covers just png/jpeg/gif/webp — anything else fell through to
  # the portal's "no such software" dialog, whose "Find Software" button tries to
  # launch gnome-software and leaves an undismissable error window behind.
  home.packages = [ pkgs.imv ];

  xdg.mimeApps = {
    enable = true;
    # This makes ~/.config/mimeapps.list a read-only symlink into the store, so
    # handlers an app would otherwise register at runtime have to be listed here.
    defaultApplications = lib.genAttrs imageTypes (_: "imv.desktop") // {
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      "x-scheme-handler/jetbrains" = "jetbrainsd.desktop";
    };
  };
}
