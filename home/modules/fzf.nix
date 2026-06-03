{
  programs.fzf = {
    enable = true;
    # Use C-r and C-t from fzf
    # Note: C-r is later used for atuin history search
    # https://github.com/junegunn/fzf?tab=readme-ov-file#key-bindings-for-command-line
    enableZshIntegration = true;
  };
}
