{ pkgs, ... }:
{
  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  home.file.".config/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-icon-theme-name=Papirus-Dark
    gtk-theme-name=Adwaita
  '';

  home.file.".config/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-icon-theme-name=Papirus-Dark
    gtk-theme-name=Adwaita
  '';

  home.file.".gtkrc-2.0".text = ''
    gtk-icon-theme-name="Papirus-Dark"
    gtk-theme-name="Adwaita"
  '';

  home.packages = with pkgs; [
    adwaita-icon-theme
    hicolor-icon-theme
    papirus-icon-theme
  ];
}
