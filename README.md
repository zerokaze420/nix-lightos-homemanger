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
hm-switch  # 同 hms
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

## tools

此配置会安装常用 CLI 工具：

- `fastfetch`
- `eza`
- `guix`

注意：Home Manager 只能安装 Guix CLI。完整 Guix 还需要系统级 `guix-daemon`、构建用户和 systemd 服务，非 NixOS 下需按发行版方式另行配置。

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

非 NixOS 上还需要手动完成系统级权限配置：

```sh
sudo usermod -aG input "$USER"
sudo setcap cap_sys_admin+p "$(readlink -f "$(command -v sunshine)")"
```

并创建 udev 规则 `/etc/udev/rules.d/85-sunshine.rules`：

```udev
KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
```

防火墙需要放行 TCP `47984/47989/47990/48010` 和 UDP `47998-48000`。

## 常用维护命令

```sh
home-manager build --flake .#tux
home-manager switch --flake .#tux
nix flake update
```
