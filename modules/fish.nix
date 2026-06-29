{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "eza --group-directories-first --icons=auto";
      ll = "eza -lh --git --group-directories-first --icons=auto";
      la = "eza -lah --git --group-directories-first --icons=auto";
      tree = "eza --tree --level=2 --group-directories-first --icons=auto";
      gs = "git status --short";
      gd = "git diff";
      ff = "fastfetch";
      hm-switch = "home-manager switch --flake ~/code/nix-homemager#tux";
      hm-bootstrap = "nix run github:nix-community/home-manager -- switch --flake ~/code/nix-homemager#tux";
    };

    shellAbbrs = {
      gco = "git checkout";
      gcm = "git commit";
      gp = "git push";
      hms = "home-manager switch --flake ~/code/nix-homemager#tux";
      hmr = "nix run github:nix-community/home-manager -- switch --flake ~/code/nix-homemager#tux";
      hmb = "home-manager build --flake ~/code/nix-homemager#tux";
      ns = "nix search nixpkgs";
    };

    functions = {
      mkcd = {
        description = "Create a directory and cd into it";
        body = ''
          mkdir -p $argv[1]; and cd $argv[1]
        '';
      };
    };

    interactiveShellInit = ''
      set -g fish_greeting
      fish_add_path -g ~/.local/bin ~/.nix-profile/bin
    '';
  };

  home.packages = with pkgs; [
    fish
  ];
}
