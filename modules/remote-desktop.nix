{ pkgs, ... }:
let
  startWayvnc = pkgs.writeShellScript "start-wayvnc" ''
    set -eu

    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

    if [ -z "''${WAYLAND_DISPLAY:-}" ] || [ ! -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
      for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
        [ -S "$socket" ] || continue
        export WAYLAND_DISPLAY="$(basename "$socket")"
        break
      done
    fi

    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      echo "No Wayland socket found under $XDG_RUNTIME_DIR" >&2
      exit 1
    fi

    exec ${pkgs.wayvnc}/bin/wayvnc \
      --render-cursor \
      --max-fps=30 \
      --log-level=info \
      0.0.0.0:5900
  '';
in
{
  home.packages = with pkgs; [
    novnc
    python3Packages.websockify
    wayvnc
  ];

  systemd.user.services.wayvnc = {
    Unit = {
      Description = "Wayland VNC server";
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${startWayvnc}";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.novnc = {
    Unit = {
      Description = "noVNC browser gateway for WayVNC";
      Wants = [ "wayvnc.service" ];
      After = [ "wayvnc.service" ];
    };

    Service = {
      ExecStart = "${pkgs.novnc}/bin/novnc --listen 0.0.0.0:6080 --vnc 127.0.0.1:5900 --file-only";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
