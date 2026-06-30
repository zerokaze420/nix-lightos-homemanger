{ pkgs, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  home.packages = with pkgs; [
    adwaita-icon-theme
    hicolor-icon-theme
    papirus-icon-theme
  ];
}
