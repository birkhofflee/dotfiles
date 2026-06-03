{ pkgs, ... }:
{
  home.packages = [ pkgs.uv ];

  xdg.configFile."uv/uv.toml".text = ''
    # Prevent supply chain attacks by ignoring packages published in the last 7 days
    exclude-newer = "7 days"
  '';
}
