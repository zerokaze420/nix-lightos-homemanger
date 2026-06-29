{ ... }:
{
  imports = [
    ./modules/dwl.nix
    ./modules/sunshine.nix
  ];

  home.username = "tux";
  home.homeDirectory = "/home/tux";

  # 首次安装请保持此值不变（仅作为状态迁移基准）。
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
