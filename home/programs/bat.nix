{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    themes = {
      "Catppuccin Macchiato" = {
        src = pkgs.catppuccin;
        file = "bat/Catppuccin Macchiato.tmTheme";
      };
    };
  };
}
