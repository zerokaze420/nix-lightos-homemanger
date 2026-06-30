{ lib, pkgs, ... }:
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
        "HDMI-A-1,3840x2160@60,auto,1"
        "HDMI-A-2,3840x2160@60,auto,1"
        ",3840x2160@60,auto,1"
      ];

      exec-once = [
        "caelestia shell -d"
        "systemctl --user restart wayvnc.service novnc.service sunshine.service"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        accel_profile = "flat";
        sensitivity = 0;
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
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
      };

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, B, exec, firefox"
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
