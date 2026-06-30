{ lib, pkgs, ... }:
let
  startHdmiHyprland = pkgs.writeShellScript "start-hdmi-hyprland" ''
    set -eu

    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=Hyprland
    export XDG_SESSION_DESKTOP=Hyprland
    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export LIBSEAT_BACKEND=seatd

    if [ -S "$XDG_RUNTIME_DIR/wayland-0" ] || pgrep -xu "$(id -u)" Hyprland >/dev/null; then
      echo "Hyprland is already running"
      exit 0
    fi

    if [ ! -r /dev/tty1 ] || [ ! -w /dev/tty1 ]; then
      echo "Cannot open /dev/tty1; grant tux rw access to tty1 before starting HDMI Hyprland" >&2
      exit 1
    fi

    exec </dev/tty1 >/dev/tty1 2>&1
    exec ${pkgs.hyprland}/bin/Hyprland
  '';
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    configType = "hyprlang";
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";

      monitor = [
        "HDMI-A-1,preferred,auto,1"
        "HDMI-A-2,preferred,auto,1"
        ",preferred,auto,1"
      ];

      exec-once = [
        "caelestia shell -d"
        "systemctl --user start wayvnc.service novnc.service sunshine.service"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
      };

      misc = {
        disable_hyprland_logo = true;
        vrr = 0;
      };

      bind = [
        "$mod, Return, exec, foot"
        "$mod, D, exec, caelestia shell launcher open"
        "$mod, Q, killactive"
        "$mod SHIFT, Q, exit"
        "$mod, F, fullscreen"
        "$mod, Space, togglefloating"
      ];
    };
  };

  xdg.dataFile."wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=An intelligent dynamic tiling Wayland compositor
    Exec=Hyprland
    Type=Application
  '';

  systemd.user.services.hyprland-hdmi = {
    Unit = {
      Description = "Hyprland HDMI session on tty1";
      After = [ "graphical-session-pre.target" ];
      Wants = [ "graphical-session-pre.target" ];
      ConditionPathExists = "/dev/tty1";
    };

    Service = {
      ExecStart = "${startHdmiHyprland}";
      Restart = "on-failure";
      RestartSec = "3s";
      StandardOutput = "journal";
      StandardError = "journal";
    };

    Install.WantedBy = [ "default.target" ];
  };

  programs.fish.loginShellInit = lib.mkAfter ''
    if test -z "$WAYLAND_DISPLAY"; and test -z "$DISPLAY"; and test (tty) = "/dev/tty1"
      exec Hyprland
    end
  '';

  home.packages = with pkgs; [
    foot
    hyprland
    seatd
    xdg-desktop-portal-hyprland
  ];
}
