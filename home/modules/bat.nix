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

  home.sessionVariables = {
    BAT_THEME = "Catppuccin Macchiato";
    LESSCOLORIZER = "bat";
    MANPAGER = "bat -plman";
  };
}
