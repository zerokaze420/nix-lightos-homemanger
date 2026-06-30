{ caelestiaShellPatched, pkgs, ... }:
{
  programs.caelestia = {
    enable = true;
    package = caelestiaShellPatched;

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
    XDG_DATA_DIRS = "$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share:/usr/local/share:/usr/share";
    XDG_CONFIG_DIRS = "$HOME/.nix-profile/etc/xdg:/nix/var/nix/profiles/default/etc/xdg:/etc/xdg";
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
