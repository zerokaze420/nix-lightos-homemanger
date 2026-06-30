#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOST="${TARGET_HOST:-lc03test.heiyu.space}"
TARGET_PORT="${TARGET_PORT:-1231}"
TARGET_USER="${TARGET_USER:-tux}"
TARGET_PASS="${TARGET_PASS:-hhj2418}"

ssh_target() {
  sshpass -p "$TARGET_PASS" ssh -F /dev/null -o StrictHostKeyChecking=no -p "$TARGET_PORT" "$TARGET_USER@$TARGET_HOST" "$@"
}

status() {
  ssh_target '
    set -e
    echo "== system services =="
    systemctl --no-pager --plain status seatd.service hyprland-hdmi.service 2>/dev/null | sed -n "1,120p" || true

    echo
    echo "== desktop processes =="
    pgrep -af "Hyprland|quickshell|caelestia|wayvnc|sunshine" || true

    echo
    echo "== input devices =="
    H="$(find /run/user/1000/hypr -maxdepth 1 -mindepth 1 -type d -printf "%f\n" 2>/dev/null | sort | tail -1)"
    if [ -n "$H" ]; then
      HYPRLAND_INSTANCE_SIGNATURE="$H" XDG_RUNTIME_DIR=/run/user/1000 hyprctl devices 2>/dev/null | sed -n "1,180p" || true
    else
      echo "Hyprland runtime was not found."
    fi
  '
}

case "${1:-restart}" in
  restart)
    exec bash "$SCRIPT_DIR/fix-lightos-hdmi-hyprland.sh"
    ;;
  status|--status)
    status
    ;;
  *)
    cat >&2 <<EOF
Usage:
  $0              Restart and repair the LightOS HDMI desktop
  $0 --status    Show remote desktop service/input status

Environment:
  TARGET_HOST=$TARGET_HOST
  TARGET_PORT=$TARGET_PORT
  TARGET_USER=$TARGET_USER
EOF
    exit 2
    ;;
esac
