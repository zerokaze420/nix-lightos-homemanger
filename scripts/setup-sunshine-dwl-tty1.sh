#!/usr/bin/env bash
set -euo pipefail

target_user="${1:-${SUDO_USER:-$USER}}"
uid="$(id -u "$target_user")"
home_dir="$(getent passwd "$target_user" | cut -d: -f6)"
dwl_bin="${home_dir}/.nix-profile/bin/dwl"
sunshine_bin="${home_dir}/.nix-profile/bin/sunshine"

if [ "$target_user" = "root" ]; then
  echo "Do not run this as root without passing the target user." >&2
  echo "Usage: $0 tux" >&2
  exit 1
fi

if [ ! -x "$dwl_bin" ]; then
  echo "dwl not found: $dwl_bin" >&2
  echo "Run home-manager switch first." >&2
  exit 1
fi

sudo groupadd -r input 2>/dev/null || true
sudo usermod -aG input,video,tty "$target_user"

render_gid="$(stat -c %g /dev/dri/renderD128 2>/dev/null || true)"
if [ -n "$render_gid" ] && ! getent group "$render_gid" >/dev/null; then
  sudo groupadd -g "$render_gid" render
fi
if getent group render >/dev/null; then
  sudo usermod -aG render "$target_user"
fi

if [ -x "$sunshine_bin" ] && command -v setcap >/dev/null 2>&1; then
  sudo setcap cap_sys_admin+p "$(readlink -f "$sunshine_bin")" || true
fi

if command -v loginctl >/dev/null 2>&1; then
  sudo loginctl enable-linger "$target_user"
fi

sudo install -d -m 0755 /etc/systemd/system
sudo tee /etc/systemd/system/dwl-tty1.service >/dev/null <<EOF
[Unit]
Description=dwl on tty1 for Sunshine
After=systemd-user-sessions.service
Conflicts=getty@tty1.service

[Service]
User=${target_user}
PAMName=login
WorkingDirectory=${home_dir}
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
TTYVTDisallocate=yes
StandardInput=tty
StandardOutput=journal+console
StandardError=journal+console
UtmpIdentifier=tty1
UtmpMode=user
Environment=XDG_RUNTIME_DIR=/run/user/${uid}
Environment=XDG_CURRENT_DESKTOP=wlroots
Environment=XDG_SESSION_TYPE=wayland
SupplementaryGroups=input video render tty
ExecStart=${dwl_bin}
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

run_user_systemctl() {
  sudo -u "$target_user" \
    XDG_RUNTIME_DIR="/run/user/${uid}" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${uid}/bus" \
    systemctl --user "$@"
}

run_user_systemctl disable --now dwl-headless.service 2>/dev/null || true
run_user_systemctl reset-failed dwl-headless.service wayvnc.service novnc.service sunshine.service 2>/dev/null || true

sudo systemctl daemon-reload
sudo systemctl disable --now getty@tty1.service
sudo systemctl enable --now dwl-tty1.service

run_user_systemctl restart wayvnc.service novnc.service sunshine.service 2>/dev/null || true

echo
echo "dwl-tty1.service:"
systemctl status dwl-tty1.service --no-pager || true

echo
echo "sunshine.service:"
run_user_systemctl status sunshine.service --no-pager || true

echo
echo "Check Sunshine logs:"
echo "  journalctl --user -u sunshine.service -n 120 --no-pager | grep -E 'HEADLESS|HDMI|Found monitor|Encoder|EGL|Fatal'"
