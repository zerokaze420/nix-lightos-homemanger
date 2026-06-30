{ pkgs, ... }:
{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "Aporetic Serif Mono" ];
      serif = [ "Aporetic Serif" ];
      sansSerif = [ "Aporetic Sans" ];
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Aporetic Serif Mono:size=12";
      };
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "Aporetic Serif Mono";
      size = 12;
    };
    settings = {
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      confirm_os_window_close = 0;
      cursor_shape = "beam";
      enable_audio_bell = false;
      remember_window_size = false;
      initial_window_width = 1100;
      initial_window_height = 720;
      window_padding_width = 8;
    };
  };

  home.packages = with pkgs; [
    aporetic-bin
    fontconfig
  ];
}
