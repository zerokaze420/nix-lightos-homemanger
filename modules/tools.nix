{ pkgs, ... }:
let
  lazycatMicroserverLogo = pkgs.fetchurl {
    url = "https://dl.lazycat.cloud/official_site/assets/cn/imgs/home_page/%E9%A6%96%E5%B1%8F/pc_%E6%89%8B%E6%8C%81%E5%BE%AE%E6%9C%8D.webp";
    name = "lazycat-microserver.webp";
    hash = "sha256-i4LpKcO2hXdp3c2Nu4G3fRB2InzrLJ3GUauRpZpE48s=";
  };
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        source = "${lazycatMicroserverLogo}";
        type = "chafa";
        width = 34;
        height = 18;
        preserveAspectRatio = true;
        chafa = {
          symbols = "block";
          canvasMode = "truecolor";
        };
        padding = {
          top = 1;
          left = 1;
          right = 3;
        };
      };
      display = {
        separator = "   ";
        color = "cyan";
        key.width = 14;
      };
      modules = [
        "title"
        "separator"
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
          type = "font";
          key = "font";
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
