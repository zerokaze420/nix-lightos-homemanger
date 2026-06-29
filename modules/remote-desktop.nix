{ pkgs, ... }:
let
  startDwlHeadless = pkgs.writeShellScript "start-dwl-headless" ''
    set -eu

    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export XDG_CURRENT_DESKTOP="wlroots"
    export WLR_BACKENDS="headless"
    export WLR_HEADLESS_OUTPUTS="1"
    export WLR_LIBINPUT_NO_DEVICES="1"
    export WLR_RENDERER="pixman"

    exec ${pkgs.dwl}/bin/dwl
  '';

  startWayvnc = pkgs.writeShellScript "start-wayvnc" ''
    set -eu

    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

    for attempt in $(seq 1 30); do
      if [ -n "''${WAYLAND_DISPLAY:-}" ] && [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
        break
      fi

      for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
        [ -S "$socket" ] || continue
        export WAYLAND_DISPLAY="$(basename "$socket")"
        break
      done

      [ -n "''${WAYLAND_DISPLAY:-}" ] && break
      sleep 1
    done

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
    dwl
    novnc
    python3Packages.websockify
    wayvnc
  ];

  systemd.user.services.dwl-headless = {
    Unit = {
      Description = "Headless dwl session for remote desktop";
    };

    Service = {
      ExecStart = "${startDwlHeadless}";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.wayvnc = {
    Unit = {
      Description = "Wayland VNC server";
      Wants = [ "dwl-headless.service" ];
      After = [ "dwl-headless.service" ];
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
