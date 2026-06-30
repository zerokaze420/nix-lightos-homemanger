{ pkgs, ... }:
let
  lazycatMicroserverLogo = ../assets/lazycat-microserver.png;
in
{
  home.file.".config/btop/btop.conf".text = ''
    # LightOS btop defaults
    color_theme = "lightos"
    theme_background = False
    truecolor = True
    rounded_corners = True
    graph_symbol = "braille"
    shown_boxes = "cpu mem net proc"
    update_ms = 1000
    proc_sorting = "cpu lazy"
    proc_reversed = False
    proc_tree = False
    proc_colors = True
    proc_gradient = True
    proc_per_core = False
    proc_mem_bytes = True
    proc_cpu_graphs = True
    cpu_graph_upper = "total"
    cpu_graph_lower = "total"
    cpu_single_graph = False
    show_uptime = True
    check_temp = True
    show_coretemp = True
    cpu_sensor = "Auto"
    show_disks = True
    only_physical = True
    use_fstab = False
    show_io_stat = True
    io_mode = False
    io_graph_combined = False
    net_download = 100
    net_upload = 100
    net_auto = True
    net_sync = False
    show_battery = False
    show_init = False
    log_level = "WARNING"
  '';

  home.file.".config/btop/themes/lightos.theme".text = ''
    theme[main_bg]="#111318"
    theme[main_fg]="#d6dbe5"
    theme[title]="#e8edf7"
    theme[hi_fg]="#ffffff"
    theme[selected_bg]="#2a303b"
    theme[selected_fg]="#ffffff"
    theme[inactive_fg]="#6f7785"
    theme[graph_text]="#aeb7c5"
    theme[meter_bg]="#252b35"
    theme[proc_misc]="#8fa1b7"
    theme[cpu_box]="#7aa2f7"
    theme[mem_box]="#9ece6a"
    theme[net_box]="#7dcfff"
    theme[proc_box]="#f7768e"
    theme[div_line]="#363d4a"
    theme[temp_start]="#9ece6a"
    theme[temp_mid]="#e0af68"
    theme[temp_end]="#f7768e"
    theme[cpu_start]="#7dcfff"
    theme[cpu_mid]="#7aa2f7"
    theme[cpu_end]="#bb9af7"
    theme[free_start]="#9ece6a"
    theme[free_mid]="#73daca"
    theme[free_end]="#7dcfff"
    theme[cached_start]="#7aa2f7"
    theme[cached_mid]="#bb9af7"
    theme[cached_end]="#ff9e64"
    theme[available_start]="#9ece6a"
    theme[available_mid]="#7dcfff"
    theme[available_end]="#bb9af7"
    theme[used_start]="#e0af68"
    theme[used_mid]="#ff9e64"
    theme[used_end]="#f7768e"
    theme[download_start]="#7dcfff"
    theme[download_mid]="#7aa2f7"
    theme[download_end]="#bb9af7"
    theme[upload_start]="#9ece6a"
    theme[upload_mid]="#e0af68"
    theme[upload_end]="#f7768e"
    theme[process_start]="#7dcfff"
    theme[process_mid]="#bb9af7"
    theme[process_end]="#f7768e"
  '';

  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        source = "${lazycatMicroserverLogo}";
        type = "kitty-direct";
        width = 28;
        height = 14;
        preserveAspectRatio = true;
        recache = true;
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
    btop
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
