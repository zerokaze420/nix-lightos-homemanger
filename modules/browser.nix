{ pkgs, ... }:
{
  home.sessionVariables = {
    BROWSER = "firefox";
    MOZ_ENABLE_WAYLAND = "1";
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles.lightos = {
      id = 0;
      isDefault = true;
      settings = {
        "browser.shell.checkDefaultBrowser" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
    };
  };

  home.packages = with pkgs; [
    xdg-utils
  ];
}
