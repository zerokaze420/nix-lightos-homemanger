# nix-homemager

Standalone Home Manager 配置，当前包含 dwl、Sunshine、fish、starship 和 nixvim 配置。

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

注意：Home Manager 只能安装 Guix CLI。完整 Guix 还需要系统级 `guix-daemon`、构建用户和 systemd 服务，非 NixOS 下需按发行版方式另行配置。

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

## dwl

配置会安装 `dwl`、`foot`、`wmenu`、`swaybg`、`wlr-randr`、`wl-clipboard`，并写入 Wayland 会话文件：

```text
~/.local/share/wayland-sessions/dwl.desktop
```

使用 SDDM/GDM/greetd 等显示管理器时，在会话列表里选择 `dwl`。非 NixOS 下设置默认会话属于系统级配置，需要在显示管理器侧完成。

无显示管理器时，此配置会在 fish 登录 shell 的 TTY1 登录后自动 `exec dwl`。若要开机后直接进入 dwl，还需要系统级自动登录 TTY1，并确保用户登录 shell 是 fish。非 NixOS 可创建：

```text
/etc/systemd/system/getty@tty1.service.d/autologin.conf
```

内容示例：

```ini
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin tux --noclear %I $TERM
```

然后执行：

```sh
sudo systemctl daemon-reload
sudo systemctl restart getty@tty1.service
```

注意：TTY 自动登录会绕过本机密码输入，只适合可信物理环境。

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

### Sunshine 使用真实 HDMI/dwl

用户级 noVNC 远程桌面使用的是 headless dwl，Sunshine 会看到 `HEADLESS-1`。这个输出适合 noVNC，但不能作为 Sunshine 游戏串流的编码源。要让 Sunshine 捕获真实 HDMI，需要启动真实 DRM/HDMI dwl 会话。

仓库里提供了一键脚本：

```sh
./scripts/setup-sunshine-dwl-tty1.sh
```

下面脚本会：

- 停用用户级 headless noVNC 远程桌面服务
- 创建系统级 `dwl-tty1.service`
- 使用 TTY1 直接启动真实 DRM dwl
- 重启 wayvnc、noVNC 和 Sunshine，让它们重新绑定真实 Wayland 会话

```sh
./scripts/setup-sunshine-dwl-tty1.sh
```

验证 Sunshine 是否抓到真实 HDMI：

```sh
journalctl --user -u sunshine.service -n 120 --no-pager | grep -E 'HEADLESS|HDMI|Found monitor|Encoder|EGL|Fatal'
```

如果仍看到 `HEADLESS-1`，说明 headless 远程桌面服务还在占用 `wayland-0`，先执行：

```sh
systemctl --user disable --now dwl-headless.service
systemctl --user reset-failed dwl-headless.service wayvnc.service novnc.service sunshine.service
sudo systemctl restart dwl-tty1.service
systemctl --user restart wayvnc.service novnc.service sunshine.service
```

## remote desktop

配置会安装并启用用户级远程桌面服务：

- `wayvnc.service`：Wayland VNC 后端，监听 `0.0.0.0:5900`
- `novnc.service`：浏览器访问入口，监听 `0.0.0.0:6080`

`dwl-headless.service` 仍会安装，但不默认启用。它只用于没有真实 dwl/HDMI 会话时手动启动：

```sh
systemctl --user start dwl-headless.service
```

在同一局域网内用浏览器访问：

```text
http://<主机IP>:6080/vnc.html?host=<主机IP>&port=6080
```

`5900` 是 VNC 协议端口，不能用 `http://<主机IP>:5900` 打开。普通 VNC 客户端可连接：

```text
<主机IP>:5900
```

headless dwl 启动后会自动打开一个 `foot` 终端。dwl 默认 Mod 键是 `Alt`，常用键位：

- `Alt+Shift+Enter`：打开 `foot`
- `Alt+p`：打开 `wmenu-run`
- `Alt+j/k`：切换窗口焦点
- `Alt+Shift+c`：关闭当前窗口
- `Alt+1..9`：切换 tag
- `Alt+Shift+q`：退出 dwl

服务状态和日志：

```sh
systemctl --user status wayvnc.service
systemctl --user status novnc.service
journalctl --user -u dwl-headless.service -f
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
