{ config, ... }:
{
  age.secrets.atuin-session = {
    file = ../../secrets/atuin-session.age;
    path = "${config.home.homeDirectory}/.local/share/atuin/session";
  };
  age.secrets.atuin-key = {
    file = ../../secrets/atuin-key.age;
    path = "${config.home.homeDirectory}/.local/share/atuin/key";
  };

  xdg.configFile."atuin/themes/catppuccin-macchiato-blue.toml".text = ''
    [theme]
    name = "catppuccin-macchiato-blue"

    [colors]
    AlertInfo = "#a6da95"
    AlertWarn = "#f5a97f"
    AlertError = "#ed8796"
    Annotation = "#8aadf4"
    Base = "#cad3f5"
    Guidance = "#939ab7"
    Important = "#ed8796"
    Title = "#8aadf4"
  '';

  programs.atuin = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      # Defaults to true. If enabled, upon hitting enter Atuin will immediately execute the command. Press tab to return to the shell and edit.
      enter_accept = false;

      ## Set this to true and Atuin will minimize motion in the UI - timers will not update live, etc.
      ## Alternatively, set env NO_MOTION=true
      prefers_reduced_motion = true;

      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "http://atuin"; # Tailscale Services
      session_path = config.age.secrets."atuin-session".path;
      key_path = config.age.secrets."atuin-key".path;

      theme.name = "catppuccin-macchiato-blue";
    };
  };
}
