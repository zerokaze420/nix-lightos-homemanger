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
      <include ignore_missing="yes">${pkgs.fontconfig.out}/etc/fonts/fonts.conf</include>

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

      <alias binding="strong">
        <family>monospace</family>
        <prefer>
          <family>JetBrainsMono Nerd Font Mono</family>
          <family>Noto Sans Mono CJK SC</family>
        </prefer>
      </alias>

      <match target="pattern">
        <test qual="any" name="family">
          <string>monospace</string>
        </test>
        <edit name="family" mode="prepend_first" binding="strong">
          <string>JetBrainsMono Nerd Font Mono</string>
        </edit>
        <edit name="family" mode="append" binding="weak">
          <string>Noto Sans Mono CJK SC</string>
        </edit>
      </match>
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
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
    fontconfig
  ];
}
