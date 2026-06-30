{ pkgs, ... }:
let
  csrfAllowedOrigins = builtins.concatStringsSep "," [
    "https://192.168.3.182:47990"
    "http://192.168.3.182:47990"
    "https://lc03test.heiyu.space:47990"
    "http://lc03test.heiyu.space:47990"
  ];
in
{
  home.packages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    sunshine
  ];

  # 以 systemd 用户服务运行 Sunshine，随用户会话自动启动。
  # 首次启动后访问 https://localhost:47990 进行配对与配置
  # （配置写入 ~/.config/sunshine/，由 Sunshine 自身管理，未在此锁定）。
  systemd.user.services.sunshine = {
    Unit = {
      Description = "Sunshine self-hosted game stream host";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [
        "FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
        "GBM_BACKENDS_PATH=${pkgs.mesa}/lib/gbm"
        "LIBGL_DRIVERS_PATH=${pkgs.mesa}/lib/dri"
        "LIBVA_DRIVERS_PATH=${pkgs.intel-media-driver}/lib/dri:${pkgs.intel-vaapi-driver}/lib/dri:${pkgs.mesa}/lib/dri"
        "WAYLAND_DISPLAY=wayland-0"
        "XDG_CURRENT_DESKTOP=Hyprland"
      ];
      ExecStart = "${pkgs.sunshine}/bin/sunshine system_tray=disabled origin_web_ui_allowed=wan csrf_allowed_origins=${csrfAllowedOrigins}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # ── 重要：非 NixOS（CachyOS/Arch）需要的系统级权限，home-manager 无法配置 ──
  #
  # 1) 虚拟手柄/键鼠 (uinput) —— 创建 udev 规则（需 root）：
  #      /etc/udev/rules.d/85-sunshine.rules
  #      KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  #    并将用户加入 input 组：  sudo usermod -aG input tux
  #
  # 2) GPU/DRM 访问权限（需 root）：
  #      sudo usermod -aG video,render tux
  #    如果 /dev/dri/renderD128 的组只有数字没有名字，需先按该 GID 创建 render 组。
  #
  # 3) Wayland 下的 KMS 屏幕捕获能力（需 root，对 nix store 二进制赋能）：
  #      sudo setcap cap_sys_admin+p "$(readlink -f "$(command -v sunshine)")"
  #    若 nix store 不可写导致 setcap 失败，可改用 X11/PipeWire 捕获后端。
  #
  # 4) 防火墙放行端口：TCP 47984/47989/47990/48010，UDP 47998-48000。
}
