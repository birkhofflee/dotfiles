# Adapted from https://github.com/malob/nix-config/blob/master/home/tmux.nix
{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    # Mouse support -- scroll wheel scrolls history, click selects panes, drag resizes
    mouse = true;

    # Zero delay for escape sequences (no lag after pressing Escape)
    escapeTime = 0;

    # Large scrollback buffer
    historyLimit = 50000;

    # Proper terminfo for italics, true color, etc.
    terminal = "tmux-256color";

    # Vi keybindings in copy mode
    keyMode = "vi";

    # Start window/pane numbering from 1
    baseIndex = 1;

    # Pass focus events through to applications
    focusEvents = true;

    plugins = with pkgs.tmuxPlugins; [
      # Makes mouse scroll feel natural: enters copy mode on scroll up,
      # exits when you reach the bottom, and emulates scroll in alternate-buffer
      # programs (less, man, etc.)
      {
        plugin = better-mouse-mode;
        extraConfig = ''
          set -g @emulate-scroll-for-no-mouse-alternate-buffer "on"
        '';
      }
    ];

    extraConfig = ''
      # True color support for Ghostty (TERM=xterm-ghostty)
      set -as terminal-features ",xterm-ghostty:RGB"

      # Renumber windows when one is closed
      set -g renumber-windows on

      # OSC 52 clipboard -- lets tmux set the system clipboard via the terminal.
      # Works natively in Ghostty and over SSH.
      set -s set-clipboard on

      # Vi-style selection and yank in copy mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel

      # Minimal status bar that adapts to light/dark via terminal palette colours
      set -g status-style "bg=default,fg=default"
      set -g status-left "#[dim] #S  "
      set -g status-left-length 20
      set -g status-right " "
      set -g window-status-format "#[dim] #I:#W "
      set -g window-status-current-format "#[bold] #I:#W "
      set -g window-status-separator ""

      # Pane borders -- bright green (base01 in Solarized), blue for active
      set -g pane-border-style "fg=colour10"
      set -g pane-active-border-style "fg=colour4"
    '';
  };
}
