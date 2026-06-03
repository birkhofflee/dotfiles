#!/usr/bin/env zsh

# Shell configuration

# Treat slashes as word separators (https://stackoverflow.com/a/11200998/2465955)
WORDCHARS=''${WORDCHARS/\/}

setopt INCAPPENDHISTORY     # Immediately append to the history file, not just when a term is killed
setopt BANG_HIST            # Treat the '!' character specially during expansion.
setopt HIST_VERIFY          # Do not execute immediately upon history expansion.
setopt HIST_BEEP            # Beep when accessing non-existent history.

# Directory Options
# @see https://github.com/sorin-ionescu/prezto/blob/master/modules/directory/init.zsh
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given.
setopt CDABLE_VARS          # Change directory to a path stored in a variable.
setopt MULTIOS              # Write to multiple descriptors.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
unsetopt CLOBBER            # Do not overwrite existing files with > and >>.
                            # Use >! and >>! to bypass.

# Don't treat non-executable files in your $path as commands. This makes sure
# they don't show up as command completions. Settinig this option can impact
# performance on older systems, but should not be a problem on modern ones.
setopt HASH_EXECUTABLES_ONLY

# Sort numbers numerically, not lexicographically.
setopt NUMERIC_GLOB_SORT

# Disable start/stop characters (^Z, ^C, etc) in shell editor, so we can use
# them as shortcuts
unsetopt FLOW_CONTROL

# This disables the original zsh behavior to put white background behind the
# pasted text.
# @see https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Character-Highlighting
zle_highlight=('paste:none')

# Remove the trailing newline from the pasted text (if any)
# @see https://unix.stackexchange.com/a/693146
bracketed-paste() {
  zle .$WIDGET && LBUFFER=${LBUFFER%%$'\n'##}
}
zle -N bracketed-paste

