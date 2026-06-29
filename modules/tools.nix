{ pkgs, ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        source = "nixos_small";
        padding = {
          top = 1;
          left = 2;
        };
      };
      display = {
        separator = "  ";
        color = "blue";
        key.width = 12;
      };
      modules = [
        "title"
        "separator"
        {
          type = "os";
          key = "os";
        }
        {
          type = "kernel";
          key = "kernel";
        }
        {
          type = "uptime";
          key = "uptime";
        }
        {
          type = "packages";
          key = "packages";
        }
        {
          type = "shell";
          key = "shell";
        }
        {
          type = "terminal";
          key = "terminal";
        }
        {
          type = "wm";
          key = "wm";
        }
        {
          type = "cpu";
          key = "cpu";
        }
        {
          type = "gpu";
          key = "gpu";
        }
        {
          type = "memory";
          key = "memory";
        }
        {
          type = "disk";
          key = "disk";
          folders = "/";
        }
        "break"
        "colors"
      ];
    };
  };

  home.packages = with pkgs; [
    eza
    guix
  ];
}
