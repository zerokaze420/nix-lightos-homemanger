{ pkgs, ... }:
{
  programs.caelestia = {
    enable = true;

    systemd = {
      enable = false;
      target = "graphical-session.target";
    };

    cli = {
      enable = true;
      settings = {
        theme.enableGtk = false;
      };
    };

    settings = {
      bar.status.showBattery = false;
    };
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  home.packages = with pkgs; [
    brightnessctl
    ddcutil
    lm_sensors
    material-symbols
    swappy
  ];
}
