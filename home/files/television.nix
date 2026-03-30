{ pkgs, ... }:
let
  catppuccinTelevision = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "television";
    rev = "4d9cfc97b0a5a6a2854c9e5f6f8fdae6a9343232";
    sha256 = "sha256-83C03FX2vb5UHq5sbad8XLoF/2EfX0NC+fUA0Xi60fw=";
  };
in
{
  xdg.configFile."television/themes/catppuccin-macchiato-blue.toml".source =
    "${catppuccinTelevision}/themes/catppuccin-macchiato-blue.toml";

  xdg.configFile."television/config.toml".text = ''
    [ui]
    theme = "catppuccin-macchiato-blue"
  '';
}
