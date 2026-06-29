{ pkgs, ... }:
let
  # 如需自定义按键 / termcmd，复制 dwl 的 config.def.h 为 ./config.h 后改用：
  #   dwl = pkgs.dwl.override { conf = ./config.h; };
  dwl = pkgs.dwl;
in
{
  home.packages = with pkgs; [
    dwl
    foot # dwl 默认终端 (termcmd)
    wmenu # dwl 默认启动器 (menucmd: wmenu-run)
    swaybg # 壁纸
    wlr-randr # 显示器配置
    wl-clipboard # 剪贴板
  ];

  # Wayland 会话入口：显示管理器 (SDDM/GDM/greetd) 会在会话列表中显示 "dwl"。
  # 注意：把 dwl 设为“默认”会话是系统级设置，需在显示管理器侧选择，
  #       home-manager（非 NixOS）无法直接控制默认会话。
  xdg.dataFile."wayland-sessions/dwl.desktop".text = ''
    [Desktop Entry]
    Name=dwl
    Comment=dwm for Wayland
    Exec=dwl
    Type=Application
  '';

  # 从 TTY1 登录后自动启动 dwl（无显示管理器时使用）。
  programs.bash = {
    enable = true;
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec dwl
      fi
    '';
  };

  programs.fish.loginShellInit = ''
    if test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
      exec dwl
    end
  '';

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "wlroots";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1"; # Electron/Chromium 走 Wayland
  };
}
