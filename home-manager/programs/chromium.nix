{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableWideVine = true;
    };

    extensions = [
      "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
    ];

    commandLineArgs = [
      # Forces Chromium to use native Wayland instead of XWayland
      "--ozone-platform-hint=wayland"
      # Core video decoding/encoding and modern canvas rendering features.
      # Vulkan/ANGLE-Vulkan removed: Chromium rejects them under --ozone-platform=wayland
      # ("not compatible with Vulkan") and falls back, so they only added error spam.
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
      # Bypasses Chromium's overly restrictive Linux GPU safety blocks
      "--ignore-gpu-blocklist"
      # Dramatically reduces CPU overhead by drawing straight to the GPU
      "--enable-zero-copy"
    ];
  };
}
