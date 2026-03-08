{ pkgs, ... }:
let
  catppuccin-yazi = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "fc69d6472d29b823c4980d23186c9c120a0ad32c";
    hash = "sha256-Og33IGS9pTim6LEH33CO102wpGnPomiperFbqfgrJjw=";
  };
in
{
  xdg.configFile."yazi/theme.toml".source =
    "${catppuccin-yazi}/themes/macchiato/catppuccin-macchiato-blue.toml";

  xdg.configFile."yazi/Catppuccin-macchiato.tmTheme".source =
    "${pkgs.catppuccin}/bat/Catppuccin Macchiato.tmTheme";

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };
}
