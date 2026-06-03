#!/usr/bin/env zsh

# Some credit goes to https://github.com/marlonrichert/zsh-launchpad

# https://stackoverflow.com/a/29403520/2465955
# note: use iTerm2 Natural Text Editing keymappings preset
# changes hex 0x15 and 0x18 0x7f to delete everything to the left of
# the cursor, rather than the whole line.
bindkey "^U" backward-kill-line
bindkey "^X\\x7f" backward-kill-line

bindkey "^B" beginning-of-line

# Alt-Q
# - On the main prompt: Push aside your current command line, so you can type a
#   new one. The old command line is re-inserted when you press Alt-G or
#   automatically on the next command line.
# - On the continuation prompt: Move all entered lines to the main prompt, so
#   you can edit the previous lines.
bindkey '^[q' push-line-or-edit

# Adds redo to 0x18 0x1f
bindkey "^X^_" redo

# Edit command line in EDITOR
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Alt-V: Show the next key combo's terminal code and state what it does.
bindkey '^[v' describe-key-briefly

# Alt-Shift-S: Prefix the current or previous command line with `sudo`.
() {
  bindkey '^[S' $1  # Bind Alt-Shift-S to the widget below.
  zle -N $1         # Create a widget that calls the function below.
  $1() {            # Create the function.
    # If the command line is empty or just whitespace, then first load the
    # previous line.
    [[ $BUFFER == [[:space:]]# ]] &&
        zle .up-history

    # $LBUFFER is the part of the command line that's left of the cursor. This
    # way, we preserve the cursor's position.
    LBUFFER="sudo $LBUFFER"
  }
} .sudo
