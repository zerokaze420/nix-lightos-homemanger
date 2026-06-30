# nix-homemager

Standalone Home Manager 配置，当前包含 Hyprland、Caelestia Shell、Sunshine、fish、starship、nixvim 和字体配置。

## 使用前调整

默认用户是 `tux`，home 目录是 `/home/tux`。如果在其他机器或其他用户下使用，先改 `home.nix`：

```nix
home.username = "你的用户名";
home.homeDirectory = "/home/你的用户名";
```

如果仓库路径不是 `~/code/nix-homemager`，同时更新 `modules/fish.nix` 里的 `hm-switch`、`hms`、`hmb`。

## 非 NixOS 使用

先在系统里安装 Nix，并启用 flakes：

```sh
mkdir -p ~/.config/nix
printf 'experimental-features = nix-command flakes\n' >> ~/.config/nix/nix.conf
```

首次应用可以不预装 Home Manager，直接用 flake 运行：

```sh
nix run github:nix-community/home-manager -- switch --flake .#tux
```

之后会安装 `home-manager` 命令，可以在仓库目录执行：

```sh
home-manager switch --flake .#tux
```

fish 配置里也提供了快捷命令：

```fish
hms        # home-manager switch --flake ~/code/nix-homemager#tux
hmb        # home-manager build --flake ~/code/nix-homemager#tux
hmr        # nix run github:nix-community/home-manager -- switch --flake ~/code/nix-homemager#tux
hm-switch  # 同 hms
hm-bootstrap # 同 hmr，用于首次没有 home-manager 命令时
```

## fish

此配置会启用 Home Manager 的 fish 支持，并加入一些常用别名、缩写和函数：

- `ls`、`ll`、`la`、`tree` 使用 `eza` 美化输出
- `gs`、`gd`
- `ff` 运行 `fastfetch`
- `gco`、`gcm`、`gp`
- `mkcd <dir>` 创建目录并进入
- 自动加入 `~/.local/bin` 和 `~/.nix-profile/bin` 到 fish PATH

Home Manager 只能安装和配置 fish，不能在非 NixOS 上替你修改登录 shell。需要的话手动执行：

```sh
command -v fish
sudo chsh -s "$(command -v fish)" "$USER"
```

重新登录后生效。

## starship

此配置会启用 starship，并打开 fish 集成。Prompt 使用 Catppuccin Mocha 配色，显示当前目录、Git 分支/状态、Nix shell、耗时命令和右侧时间。

语言识别包含常见项目语言，并额外通过自定义模块识别：

- Nix：`*.nix`、`flake.nix`、`default.nix`、`shell.nix`、`home.nix`
- Guix：`manifest.scm`、`channels.scm`、`guix.scm`

## tools

此配置会安装常用 CLI 工具：

- `fastfetch`
- `eza`
- `ripgrep`
- `fd`
- `uv`
- `nodejs_22`
- 网络排障工具：`dnsutils`、`traceroute`、`netcat-openbsd`、`tcpdump`、`net-tools`、`lsof`、`iproute2`、`iputils`
- `guix`

`fastfetch` 配置使用 LazyCat 微服图片的 `chafa` 彩色字符 logo，固定显示 `system = LightOS`、`host = lazycat`，并按 shell/desktop/font、cpu/gpu/memory/disk/local ip 分组输出，fish 里可直接用 `ff` 调用。

注意：Home Manager 只能安装 Guix CLI。完整 Guix 还需要系统级 `guix-daemon`、构建用户和 systemd 服务，非 NixOS 下需按发行版方式另行配置。

## fonts

默认字体配置为 Aporetic Nerd Font：

```text
monospace: Aporetic Serif Mono
serif:     Aporetic Serif
sans:      Aporetic Sans
```

`foot` 终端显式使用 `Aporetic Serif Mono:size=12`。LightOS HDMI 脚本会自动查找 Nix store 里的 `fontconfig` 默认 `fonts.conf` 并写入系统服务，避免 Hyprland/Caelestia 在非标准登录环境里找不到 fontconfig 默认配置。

## mirrors

此配置会写入常用国内镜像源：

- npm：`~/.npmrc`
- pip：`~/.config/pip/pip.conf`
- uv：`~/.config/uv/uv.toml`

## nixvim

此配置会启用 nixvim，并把 `nvim` 设置为默认编辑器，同时提供：

- 基础编辑选项：行号、相对行号、系统剪贴板、持久 undo、2 空格缩进
- 常用插件：Telescope、Treesitter、Lualine、Which-key、Gitsigns、Comment、Oil
- LSP/补全：Nix、Lua、Shell、JSON、YAML
- 常用快捷键：`<leader>ff` 查文件、`<leader>fg` 搜全文、`<leader>e` 打开 Oil、`gd` 跳定义、`K` 看 hover

## Hyprland + Caelestia Shell

配置会安装 `Hyprland`、`Caelestia Shell`、`foot`、`seatd` 和 `xdg-desktop-portal-hyprland`，并写入 Wayland 会话文件：

```text
~/.local/share/wayland-sessions/hyprland.desktop
```

使用 SDDM/GDM/greetd 等显示管理器时，在会话列表里选择 `Hyprland`。非 NixOS 下设置默认会话属于系统级配置，需要在显示管理器侧完成。

当前 Hyprland 键位：

```text
Super + Enter      打开 kitty 终端
Super + D          打开 Caelestia 应用启动器
Super + Q          关闭当前窗口
Super + Shift + Q  退出 Hyprland
Super + F          当前窗口全屏
Super + Space      当前窗口切换浮动
```

无显示管理器时，此配置会在 fish 登录 shell 的 TTY1 登录后自动 `exec Hyprland`。LightOS 容器里不建议依赖 TTY 登录路径，优先使用仓库脚本创建系统级 HDMI 会话。

### LightOS HDMI 自启动

仓库提供了 LightOS/runc 容器专用修复脚本：

```sh
bash scripts/fix-lightos-hdmi-hyprland.sh
```

日常只想一键重启 HDMI 桌面时，使用更短的入口：

```sh
bash scripts/restart-lightos-desktop.sh
```

只查看远端服务和键鼠状态：

```sh
bash scripts/restart-lightos-desktop.sh --status
```

脚本默认部署到：

```text
ssh -p 1231 tux@lc03test.heiyu.space
```

并通过宿主机：

```text
ssh root@lc03test.heiyu.space
```

完成 `/dev/tty1` 权限修复。脚本会在容器里创建并启用：

```ini
seatd.service
hyprland-hdmi.service
```

它会停止 `getty@tty1.service`，用 `seatd` 让 Hyprland 抢真实 HDMI/DRM，并补齐 `/run/opengl-driver` 的 Mesa/GLVND 链接。

验证当前 HDMI 桌面状态：

```sh
sshpass -p hhj2418 ssh -F /dev/null -p 1231 tux@lc03test.heiyu.space \
  'systemctl --no-pager --plain status seatd.service hyprland-hdmi.service;
   pgrep -af "Hyprland|quickshell|caelestia|wayvnc|sunshine"'
```

查看 Hyprland 是否识别到 Sunshine 键鼠透传：

```sh
sshpass -p hhj2418 ssh -F /dev/null -p 1231 tux@lc03test.heiyu.space \
  'H=$(find /run/user/1000/hypr -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort | tail -1);
   HYPRLAND_INSTANCE_SIGNATURE="$H" XDG_RUNTIME_DIR=/run/user/1000 hyprctl devices'
```

如果输出里有 `keyboard-passthrough` 且 `main: yes`，键盘已经被 Hyprland 接管；如果有 `mouse-passthrough`，鼠标也已经被识别。

### Caelestia 启动器找不到应用

Caelestia 启动器依赖 `.desktop` 文件。应用一般来自这些目录：

```text
~/.nix-profile/share/applications
/nix/var/nix/profiles/default/share/applications
/usr/local/share/applications
/usr/share/applications
```

LightOS HDMI 会话由系统级 `hyprland-hdmi.service` 启动，不经过普通登录 shell，所以脚本显式设置了：

```text
XDG_DATA_DIRS=~/.nix-profile/share:/nix/var/nix/profiles/default/share:/usr/local/share:/usr/share
XDG_CONFIG_DIRS=~/.nix-profile/etc/xdg:/nix/var/nix/profiles/default/etc/xdg:/etc/xdg
```

应用启动器仍为空时，先确认应用是否真的有 desktop 文件：

```sh
find ~/.nix-profile/share/applications /nix/var/nix/profiles/default/share/applications /usr/share/applications \
  -maxdepth 1 -name '*.desktop' 2>/dev/null | sort | sed -n '1,80p'
```

如果这里为空，说明还没有安装带 GUI desktop entry 的应用；如果这里有内容但启动器为空，重跑 LightOS HDMI 脚本并重启 `hyprland-hdmi.service`。

## Sunshine

配置会安装 Sunshine，并创建 systemd 用户服务。首次启动后访问：

```text
https://localhost:47990
```

局域网访问时使用 HTTPS，并确认证书警告：

```text
https://<主机IP>:47990
```

此配置已为 `192.168.3.182:47990` 和 `lc03test.heiyu.space:47990` 添加 `csrf_allowed_origins`。如果换了主机 IP 或域名，需要同步更新 `modules/sunshine.nix`。

非 NixOS 下 Sunshine 服务会显式设置 Mesa/VAAPI/GBM 驱动路径，避免 Nix 包默认查找 `/run/opengl-driver`。

非 NixOS 上还需要手动完成系统级权限配置：

```sh
getent group input >/dev/null || sudo groupadd -r input
sudo usermod -aG input "$USER"
sudo usermod -aG video "$USER"
render_gid="$(stat -c %g /dev/dri/renderD128 2>/dev/null || true)"
if [ -n "$render_gid" ] && ! getent group "$render_gid" >/dev/null; then
  sudo groupadd -g "$render_gid" render
fi
getent group render >/dev/null && sudo usermod -aG render "$USER"
sudo setcap cap_sys_admin+p "$(readlink -f "$(command -v sunshine)")"
```

并创建 udev 规则 `/etc/udev/rules.d/85-sunshine.rules`：

```udev
KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
```

加载 uinput 并刷新 udev 规则：

```sh
sudo modprobe uinput
sudo udevadm control --reload-rules
sudo udevadm trigger
```

重新登录后确认权限：

```sh
id
getcap "$(readlink -f "$(command -v sunshine)")"
ls -l /dev/uinput
```

`id` 输出里应包含 `input` 组，`/dev/uinput` 的组也应是 `input`。如果不想重新登录，可临时执行 `newgrp input`。

防火墙需要放行 TCP `47984/47989/47990/48010` 和 UDP `47998-48000`。

### Sunshine 使用真实 HDMI

Sunshine 要捕获真实 HDMI 时，使用上面的 LightOS HDMI 自启动脚本，让 `hyprland-hdmi.service` 接管 `/dev/tty1`、DRM 和 Sunshine 透传输入。不要再启动旧的 headless/dwl 会话，否则 Sunshine 可能绑定到错误的 Wayland 输出。

## remote desktop

配置会安装并启用用户级远程桌面服务：

- `wayvnc.service`：Wayland VNC 后端，监听 `0.0.0.0:5900`
- `novnc.service`：浏览器访问入口，监听 `0.0.0.0:6080`

在同一局域网内用浏览器访问：

```text
http://<主机IP>:6080/vnc.html?host=<主机IP>&port=6080
```

`5900` 是 VNC 协议端口，不能用 `http://<主机IP>:5900` 打开。普通 VNC 客户端可连接：

```text
<主机IP>:5900
```

服务状态和日志：

```sh
systemctl --user status wayvnc.service
systemctl --user status novnc.service
journalctl --user -u wayvnc.service -f
journalctl --user -u novnc.service -f
```

此配置是用户级服务，不写入 `/etc/systemd/system`。如果系统防火墙默认拦截入站连接，需要放行 TCP `5900` 和 `6080`。

## 常用维护命令

```sh
home-manager build --flake .#tux
home-manager switch --flake .#tux
nix flake update
```
