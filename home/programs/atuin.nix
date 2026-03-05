# Manual one-time setup for sync is required:
# $ atuin login
{
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
      sync_address = "http://homelab-nuc:8010";
    };
  };
}
