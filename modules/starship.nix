{ ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      add_newline = false;
      command_timeout = 1000;

      format = "[╭─](overlay0)$directory$git_branch$git_status$nix_shell$cmd_duration\n[╰─](overlay0)$character";
      right_format = "$time";
      palette = "catppuccin_mocha";

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        sky = "#89dceb";
        lavender = "#b4befe";
        mauve = "#cba6f7";
        red = "#f38ba8";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        overlay0 = "#6c7086";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold peach)";
      };

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "bold lavender";
        read_only = " ro";
        read_only_style = "red";
        truncation_length = 3;
        truncate_to_repo = false;
      };

      git_branch = {
        symbol = "git:";
        style = "bold mauve";
        format = "on [$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold yellow";
        format = "([$all_status$ahead_behind]($style)) ";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        up_to_date = "";
        untracked = "?\${count}";
        stashed = "$";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "x\${count}";
      };

      nix_shell = {
        symbol = "nix:";
        style = "bold sky";
        format = "via [$symbol$name]($style) ";
      };

      cmd_duration = {
        min_time = 1000;
        style = "subtext1";
        format = "took [$duration]($style) ";
      };

      time = {
        disabled = false;
        format = "[$time]($style)";
        style = "overlay0";
        time_format = "%H:%M";
      };
    };
  };
}
