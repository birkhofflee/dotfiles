{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    settings.color_theme = "catppuccin_macchiato";
  };
  xdg.configFile."btop/themes/catppuccin_macchiato.theme".source =
    "${pkgs.catppuccin}/btop/catppuccin_macchiato.theme";
}
