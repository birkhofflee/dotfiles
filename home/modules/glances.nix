{ pkgs, ... }:
{
  home.packages = [
    pkgs.glances # https://github.com/nicolargo/glances (system monitor)
  ];
}
