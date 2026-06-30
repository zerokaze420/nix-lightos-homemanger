#!/usr/bin/env bash
set -euo pipefail

TARGET_HOST="${TARGET_HOST:-lc03test.heiyu.space}"
TARGET_PORT="${TARGET_PORT:-1231}"
TARGET_USER="${TARGET_USER:-tux}"
TARGET_PASS="${TARGET_PASS:-hhj2418}"
SUDO_PASS="${SUDO_PASS:-$TARGET_PASS}"
HOST_ROOT="${HOST_ROOT:-root@$TARGET_HOST}"
HOST_ROOT_PASS="${HOST_ROOT_PASS:-1}"

ssh_target() {
  sshpass -p "$TARGET_PASS" ssh -F /dev/null -o StrictHostKeyChecking=no -p "$TARGET_PORT" "$TARGET_USER@$TARGET_HOST" "$@"
}

ssh_host_root() {
  sshpass -p "$HOST_ROOT_PASS" ssh -F /dev/null -o StrictHostKeyChecking=no "$HOST_ROOT" "$@"
}

copy_self() {
  sshpass -p "$TARGET_PASS" scp -F /dev/null -o StrictHostKeyChecking=no -P "$TARGET_PORT" "$0" "$TARGET_USER@$TARGET_HOST:/tmp/fix-lightos-hdmi-hyprland.sh"
}

remote_run() {
  ssh_target "TARGET_USER='$TARGET_USER' SUDO_PASS='$SUDO_PASS' bash /tmp/fix-lightos-hdmi-hyprland.sh --remote"
}

if [[ "${1:-}" != "--remote" ]]; then
  echo "[host] granting tty1 access to group tty"
  ssh_host_root 'chmod 0660 /dev/tty1; chgrp tty /dev/tty1; install -d /etc/udev/rules.d; printf "%s\n" "KERNEL==\"tty1\", GROUP=\"tty\", MODE=\"0660\"" > /etc/udev/rules.d/99-lightos-hdmi-tty1.rules; ls -l /dev/tty1'

  echo "[target] copying and running remote fix"
  copy_self
  remote_run
  exit 0
fi

sudo_cmd() {
  printf '%s\n' "$SUDO_PASS" | sudo -S "$@"
}

need_bin() {
  command -v "$1" >/dev/null || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

find_one() {
  local pattern="$1"
  find /nix/store -path "$pattern" 2>/dev/null | sort | tail -n 1
}

need_bin Hyprland
need_bin seatd

HYPRLAND_BIN="$(command -v Hyprland)"
SEATD_BIN="$(command -v seatd)"
MESA_GBM="$(find_one '*/lib/gbm/dri_gbm.so')"
MESA_DRI_DIR="$(dirname "$(find_one '*/lib/dri/iris_dri.so')")"
INTEL_MEDIA_DRI="$(dirname "$(find_one '*/lib/dri/iHD_drv_video.so')")"
MESA_LIB_DIR="$(dirname "$(find_one '*/lib/libEGL_mesa.so')")"
GLVND_LIB_DIR="$(dirname "$(find_one '*/lib/libEGL.so.1')")"
GBM_LIB_DIR="$(dirname "$(find_one '*/lib/libgbm.so.1')")"
EGL_VENDOR_JSON="$(find_one '*/share/glvnd/egl_vendor.d/50_mesa.json')"

if [[ -z "$MESA_GBM" || ! -e "$MESA_GBM" ]]; then
  echo "could not find Mesa GBM driver in /nix/store" >&2
  exit 1
fi

if [[ -z "$MESA_DRI_DIR" || ! -d "$MESA_DRI_DIR" ]]; then
  echo "could not find Mesa DRI driver directory in /nix/store" >&2
  exit 1
fi

echo "[target] Hyprland: $HYPRLAND_BIN"
echo "[target] seatd: $SEATD_BIN"
echo "[target] Mesa GBM: $MESA_GBM"
echo "[target] Mesa DRI: $MESA_DRI_DIR"
echo "[target] Intel media DRI: ${INTEL_MEDIA_DRI:-missing}"
echo "[target] Mesa lib: ${MESA_LIB_DIR:-missing}"
echo "[target] GLVND lib: ${GLVND_LIB_DIR:-missing}"
echo "[target] GBM lib: ${GBM_LIB_DIR:-missing}"
echo "[target] EGL vendor: ${EGL_VENDOR_JSON:-missing}"

echo "[target] stopping conflicting services"
systemctl --user disable --now hyprland-hdmi.service 2>/dev/null || true
systemctl --user reset-failed hyprland-hdmi.service 2>/dev/null || true
sudo_cmd systemctl stop hyprland-hdmi.service seatd.service getty@tty1.service 2>/dev/null || true
sudo_cmd systemctl reset-failed hyprland-hdmi.service seatd.service getty@tty1.service 2>/dev/null || true

echo "[target] installing /run/opengl-driver links"
sudo_cmd install -d \
  /run/opengl-driver/lib \
  /run/opengl-driver/lib/gbm \
  /run/opengl-driver/lib/dri \
  /run/opengl-driver/share/glvnd/egl_vendor.d
sudo_cmd ln -sfn "$MESA_GBM" /run/opengl-driver/lib/gbm/dri_gbm.so
if [[ -n "${MESA_LIB_DIR:-}" && -d "$MESA_LIB_DIR" ]]; then
  for lib in "$MESA_LIB_DIR"/libEGL_mesa.so* "$MESA_LIB_DIR"/libGLX_mesa.so*; do
    [[ -e "$lib" ]] || continue
    sudo_cmd ln -sfn "$lib" "/run/opengl-driver/lib/$(basename "$lib")"
  done
fi
if [[ -n "${GLVND_LIB_DIR:-}" && -d "$GLVND_LIB_DIR" ]]; then
  for lib in "$GLVND_LIB_DIR"/libEGL.so* "$GLVND_LIB_DIR"/libGLdispatch.so*; do
    [[ -e "$lib" ]] || continue
    sudo_cmd ln -sfn "$lib" "/run/opengl-driver/lib/$(basename "$lib")"
  done
fi
if [[ -n "${GBM_LIB_DIR:-}" && -d "$GBM_LIB_DIR" ]]; then
  for lib in "$GBM_LIB_DIR"/libgbm.so*; do
    [[ -e "$lib" ]] || continue
    sudo_cmd ln -sfn "$lib" "/run/opengl-driver/lib/$(basename "$lib")"
  done
fi
if [[ -n "${EGL_VENDOR_JSON:-}" && -e "$EGL_VENDOR_JSON" ]]; then
  sudo_cmd ln -sfn "$EGL_VENDOR_JSON" /run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json
fi
for driver in "$MESA_DRI_DIR"/*_dri.so; do
  sudo_cmd ln -sfn "$driver" "/run/opengl-driver/lib/dri/$(basename "$driver")"
done
if [[ -n "${INTEL_MEDIA_DRI:-}" && -d "$INTEL_MEDIA_DRI" ]]; then
  for driver in "$INTEL_MEDIA_DRI"/*_drv_video.so; do
    [[ -e "$driver" ]] || continue
    sudo_cmd ln -sfn "$driver" "/run/opengl-driver/lib/dri/$(basename "$driver")"
  done
fi

echo "[target] installing system services"
cat > /tmp/seatd.service <<EOF
[Unit]
Description=Seat management daemon for HDMI compositor
After=systemd-logind.service

[Service]
Type=simple
ExecStart=$SEATD_BIN -g video
Restart=on-failure
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

cat > /tmp/hyprland-hdmi.service <<EOF
[Unit]
Description=Hyprland HDMI session for tux on tty1
After=seatd.service systemd-user-sessions.service dbus.service
Requires=seatd.service
Conflicts=getty@tty1.service

[Service]
Type=simple
User=$TARGET_USER
WorkingDirectory=/home/$TARGET_USER
Environment=HOME=/home/$TARGET_USER
Environment=USER=$TARGET_USER
Environment=LOGNAME=$TARGET_USER
Environment=SHELL=/home/$TARGET_USER/.nix-profile/bin/fish
Environment=PATH=/home/$TARGET_USER/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin
Environment=XDG_SESSION_TYPE=wayland
Environment=XDG_CURRENT_DESKTOP=Hyprland
Environment=XDG_SESSION_DESKTOP=Hyprland
Environment=XDG_RUNTIME_DIR=/run/user/1000
Environment=LIBSEAT_BACKEND=seatd
Environment=SEATD_SOCK=/run/seatd.sock
Environment=MOZ_ENABLE_WAYLAND=1
Environment=NIXOS_OZONE_WL=1
Environment=GBM_BACKENDS_PATH=/run/opengl-driver/lib/gbm
Environment=LIBGL_DRIVERS_PATH=/run/opengl-driver/lib/dri
Environment=LIBVA_DRIVERS_PATH=/run/opengl-driver/lib/dri
Environment=LD_LIBRARY_PATH=/run/opengl-driver/lib
Environment=__EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d
Environment=__GLX_VENDOR_LIBRARY_NAME=mesa
ExecStartPre=/bin/mkdir -p /run/user/1000
ExecStartPre=/bin/chown $TARGET_USER:$TARGET_USER /run/user/1000
ExecStart=$HYPRLAND_BIN
Restart=on-failure
RestartSec=3
StandardInput=tty-force
StandardOutput=journal
StandardError=journal
TTYPath=/dev/tty1
UtmpIdentifier=tty1
UtmpMode=user

[Install]
WantedBy=multi-user.target
EOF

sudo_cmd install -m 0644 /tmp/seatd.service /etc/systemd/system/seatd.service
sudo_cmd install -m 0644 /tmp/hyprland-hdmi.service /etc/systemd/system/hyprland-hdmi.service
sudo_cmd systemctl daemon-reload
sudo_cmd systemctl disable --now getty@tty1.service 2>/dev/null || true
sudo_cmd systemctl enable --now seatd.service hyprland-hdmi.service

echo "[target] waiting for Hyprland"
sleep 8

has_passthrough_input() {
  grep -R -E 'Mouse passthrough|Keyboard passthrough|Touch passthrough|Pen passthrough' \
    /sys/class/input/event*/device/name >/dev/null 2>&1
}

hyprland_has_passthrough_fd() {
  local hpid
  hpid="$(pidof Hyprland .Hyprland-wrapp 2>/dev/null | awk '{print $1}')"
  [[ -n "$hpid" ]] || return 1
  for fd in /proc/"$hpid"/fd/*; do
    local target name
    target="$(readlink "$fd" 2>/dev/null || true)"
    case "$target" in
      /dev/input/event*)
        name="$(cat "/sys/class/input/${target##*/}/device/name" 2>/dev/null || true)"
        case "$name" in
          *"Mouse passthrough"*|*"Keyboard passthrough"*|*"Touch passthrough"*|*"Pen passthrough"*)
            return 0
            ;;
        esac
        ;;
    esac
  done
  return 1
}

if has_passthrough_input && ! hyprland_has_passthrough_fd; then
  echo "[target] passthrough input exists but Hyprland did not open it; restarting Hyprland once"
  sudo_cmd systemctl restart hyprland-hdmi.service
  sleep 8
fi

if ! pgrep -af 'caelestia|quickshell' >/dev/null 2>&1; then
  echo "[target] starting Caelestia shell"
  H="$(find /run/user/1000/hypr -maxdepth 1 -mindepth 1 -type d -printf '%f\n' 2>/dev/null | sort | tail -1)"
  if [[ -n "$H" && -S /run/user/1000/wayland-1 ]]; then
    sudo_cmd -u "$TARGET_USER" env \
      HOME="/home/$TARGET_USER" \
      USER="$TARGET_USER" \
      LOGNAME="$TARGET_USER" \
      PATH="/home/$TARGET_USER/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin" \
      XDG_RUNTIME_DIR=/run/user/1000 \
      WAYLAND_DISPLAY=wayland-1 \
      HYPRLAND_INSTANCE_SIGNATURE="$H" \
      XDG_CURRENT_DESKTOP=Hyprland \
      XDG_SESSION_TYPE=wayland \
      caelestia shell -d >/tmp/caelestia-shell-start.log 2>&1 &
    sleep 3
  fi
fi

echo "== service status =="
sudo_cmd systemctl --no-pager --plain status seatd.service hyprland-hdmi.service | sed -n '1,220p' || true

echo "== runtime =="
ls -l /run/seatd.sock /run/opengl-driver/lib/gbm/dri_gbm.so 2>/dev/null || true
ls -la /run/user/1000/wayland-* 2>/dev/null || true
pgrep -af 'Hyprland|caelestia|wayvnc|sunshine' || true

echo "== hyprland fd =="
HPID="$(pidof Hyprland .Hyprland-wrapp 2>/dev/null | awk '{print $1}')"
if [[ -n "$HPID" ]]; then
  for fd in /proc/"$HPID"/fd/*; do
    printf '%s -> ' "$fd"
    readlink "$fd" 2>/dev/null || true
  done | sed -n '1,180p'
else
  echo "Hyprland is not running"
fi

echo "== recent logs =="
sudo_cmd journalctl -u seatd.service -u hyprland-hdmi.service -n 120 --no-pager || true

echo "== latest hyprland crash report =="
latest_crash="$(ls -t "/home/$TARGET_USER/.cache/hyprland"/hyprlandCrashReport*.txt 2>/dev/null | head -n 1 || true)"
if [[ -n "$latest_crash" ]]; then
  echo "$latest_crash"
  sed -n '1,220p' "$latest_crash"
else
  echo "no Hyprland crash report found"
fi

echo "== graphics runtime hints =="
printf 'GBM_BACKENDS_PATH=%s\n' /run/opengl-driver/lib/gbm
printf 'LIBGL_DRIVERS_PATH=%s\n' /run/opengl-driver/lib/dri
printf 'LIBVA_DRIVERS_PATH=%s\n' /run/opengl-driver/lib/dri
printf 'LD_LIBRARY_PATH=%s\n' /run/opengl-driver/lib
printf '__EGL_VENDOR_LIBRARY_DIRS=%s\n' /run/opengl-driver/share/glvnd/egl_vendor.d
find /run/opengl-driver -maxdepth 4 \( -type l -o -type f \) 2>/dev/null | sort | sed -n '1,180p'
