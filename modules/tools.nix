{ pkgs, ... }:
let
  lazycatMicroserverLogo = ../assets/lazycat-microserver.png;
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        source = "${lazycatMicroserverLogo}";
        type = "chafa";
        width = 42;
        height = 20;
        preserveAspectRatio = true;
        recache = true;
        chafa = {
          symbols = "block";
        };
        padding = {
          top = 1;
          left = 1;
          right = 3;
        };
      };
      display = {
        pipe = false;
        showErrors = true;
        separator = "   ";
        color = "cyan";
        key.width = 14;
      };
      modules = [
        {
          type = "custom";
          key = "system";
          format = "LightOS";
        }
        {
          type = "kernel";
          key = "kernel";
        }
        {
          type = "custom";
          key = "host";
          format = "lazycat";
        }
        {
          type = "uptime";
          key = "uptime";
        }
        "break"
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
          key = "desktop";
        }
        {
          type = "custom";
          key = "font";
          format = "JetBrainsMono Nerd Font Mono 12";
        }
        "break"
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
        {
          type = "localip";
          key = "local ip";
          showIpv4 = true;
          showIpv6 = false;
        }
        "break"
        "colors"
      ];
    };
  };

  home.packages = with pkgs; [
    chafa
    dnsutils
    eza
    fd
    guix
    iproute2
    iputils
    lsof
    netcat-openbsd
    net-tools
    nodejs_22
    ripgrep
    tcpdump
    traceroute
    uv
  ];
}
