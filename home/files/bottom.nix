{ pkgs, ... }:
{
  xdg.configFile."bottom/bottom.toml".source = "${pkgs.catppuccin}/bottom/macchiato.toml";
}
