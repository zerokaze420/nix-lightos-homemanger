{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
    guix
  ];
}
