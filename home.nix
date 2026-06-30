{ ... }:
{
  imports = [
    ./modules/appearance.nix
    ./modules/browser.nix
    ./modules/caelestia-shell.nix
    ./modules/fish.nix
    ./modules/fonts.nix
    ./modules/hyprland.nix
    ./modules/mirrors.nix
    ./modules/nixvim.nix
    ./modules/remote-desktop.nix
    ./modules/starship.nix
    ./modules/sunshine.nix
    ./modules/tools.nix
  ];

  home.username = "tux";
  home.homeDirectory = "/home/tux";

  # 首次安装请保持此值不变（仅作为状态迁移基准）。
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
