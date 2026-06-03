{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
  ];

  home.file.".npmrc".text = ''
    # Prevent supply chain attacks by ignoring packages published in the last 7 days
    min-release-age=7
  '';
}
