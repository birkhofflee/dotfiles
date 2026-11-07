{ config, lib, ... }:
{
  programs.fzf = {
    enable = true;

    # Use C-t from fzf
    # https://github.com/junegunn/fzf?tab=readme-ov-file#key-bindings-for-command-line
    enableZshIntegration = true;

    # Leave Ctrl-R to Atuin where it's enabled
    historyWidget.command = lib.mkIf config.programs.atuin.enable "";
  };
}
