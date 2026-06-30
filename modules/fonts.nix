{ pkgs, ... }:
{
  home.sessionVariables.FONTCONFIG_FILE = "$HOME/.config/fontconfig/fonts.conf";

  programs.fish.interactiveShellInit = ''
    set -gx FONTCONFIG_FILE "$HOME/.config/fontconfig/fonts.conf"
  '';

  home.file.".config/fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <cachedir>~/.cache/fontconfig</cachedir>

      <dir>~/.nix-profile/share/fonts</dir>
      <dir>~/.nix-profile/lib/X11/fonts</dir>
      <dir>/nix/var/nix/profiles/default/share/fonts</dir>
      <dir>/usr/local/share/fonts</dir>
      <dir>/usr/share/fonts</dir>

      <include ignore_missing="yes">~/.config/fontconfig/conf.d</include>
      <include ignore_missing="yes">~/.nix-profile/etc/fonts/conf.d</include>
      <include ignore_missing="yes">/nix/var/nix/profiles/default/etc/fonts/conf.d</include>
      <include ignore_missing="yes">/etc/fonts/conf.d</include>
    </fontconfig>
  '';
  home.file.".fonts.conf".source = pkgs.writeText "fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <include ignore_missing="yes">~/.config/fontconfig/fonts.conf</include>
    </fontconfig>
  '';

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "JetBrainsMono Nerd Font Mono"
        "Noto Sans Mono CJK SC"
      ];
      serif = [ "Aporetic Serif" ];
      sansSerif = [ "Aporetic Sans" ];
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font Mono:size=12";
      };
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 12;
    };
    settings = {
      bold_font = "JetBrainsMono Nerd Font Mono Bold";
      italic_font = "JetBrainsMono Nerd Font Mono Italic";
      bold_italic_font = "JetBrainsMono Nerd Font Mono Bold Italic";
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
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
    fontconfig
  ];
}
