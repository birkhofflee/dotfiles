#!/usr/bin/env zsh

# =========================
# fzf (https://github.com/junegunn/fzf)
#
# Shell integration binds C-t, C-r, Alt-C
# @see https://github.com/junegunn/fzf?tab=readme-ov-file#key-bindings-for-command-line
# =========================

typeset -A __FZF __FZF_TAB

# Preview a file or an image in the preview window of fzf:
# https://github.com/junegunn/fzf/blob/master/bin/fzf-preview.sh

# =========================
# COMMON COMMANDS USED IN PREVIEW
# =========================
__FZF[PREVIEW_DIR]="eza -a --tree --level 3 --color=always --icons --no-quotes --group-directories-first --show-symlinks"

__FZF[PREVIEW_FILE_OR_DIR]="
  if [ -d {} ]; then
    ${__FZF[PREVIEW_DIR]} {};
  else
    less {};
  fi
"

__FZF_TAB[PREVIEW_FILE_OR_DIR]="
  if [ -d \$realpath ]; then
    ${__FZF[PREVIEW_DIR]} \$realpath;
  else
    less \$realpath;
  fi
"

# Catppuccin Macchiato. Shared with fzf-tab, which ignores FZF_DEFAULT_OPTS.
__FZF_COLORS=(
  '--color=header:italic'
  '--color=bg:#24273a,bg+:#363a4f,spinner:#f4dbd6,hl:#ed8796'
  '--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6'
  '--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796'
  '--color=selected-bg:#494d64,border:#363a4f,label:#cad3f5'
)

# TAB / Shift-TAB: multiple selections
# Alt-Up: preview page up, Alt-Down: preview page down
# ?: toggle preview window
# ^O: open with $VISUAL (`code` on macOS)
export FZF_DEFAULT_OPTS="
  ${__FZF_COLORS[*]}
  --style full
  --multi
  --bind 'alt-up:preview-page-up'
  --bind 'alt-down:preview-page-down'
  --bind 'ctrl-o:execute($VISUAL {})+abort'
  --bind '?:toggle-preview'
"

# Only for the widgets below; FZF_DEFAULT_OPTS reaches every program that runs fzf.
__FZF[HEADER]="--header '?: preview, alt-up: pgup, alt-down: pgdown, ^o: open editor'"

# =========================
# FZF - File Browser (C-t) and Alt-C
# Override FZF_CTRL_T_COMMAND and FZF_ALT_C_COMMAND to use fd and xargs
# @see https://github.com/niksingh710/cdots/blob/bc79fa30cd62f5655b45c64cc79401082b4bd791/home/.shell/fzf.zsh#L101-L106
# =========================
#
# Explanation of the options:
# -0: tells both fd and xargs to use a null character (\0) as a separator
#     instead of whitespace, which avoids issues with filenames containing
#     spaces, quotes, or other special characters.
# -tf: only regular files
# --follow: follow symlinks
# -H: follow hidden files
# -d: only directories
# -t: sort by modification time
exclude_list=(
  "--exclude .git"
  "--exclude .direnv"
  "--exclude node_modules"
  "--exclude .DS_Store"
)
export FZF_CTRL_T_COMMAND="fd -H -tf --follow ${exclude_list[*]} -0 | xargs -0 ls -t"
export FZF_ALT_C_COMMAND="fd -td ${exclude_list[*]} -0 | xargs -0 ls -dt"
unset exclude_list

# C-r is left to atuin; fzf.nix sets FZF_CTRL_R_COMMAND="" so fzf doesn't bind it.

# FZF - File Browser (C-t)
export FZF_CTRL_T_OPTS="
  ${__FZF[HEADER]}
  --preview '${__FZF[PREVIEW_FILE_OR_DIR]}'
  --preview-window right:60%:border:wrap"

# FZF - Interactive change directory (Alt-C)
export FZF_ALT_C_OPTS="
  ${__FZF[HEADER]}
  --preview '${__FZF[PREVIEW_DIR]} {}'"

# =========================
# COMPLETION OPTIONS - USING FZF-TAB (https://github.com/Aloxaf/fzf-tab)
# @see https://github.com/junegunn/fzf?tab=readme-ov-file#customizing-fzf-options-for-completion
# =========================

# `${(Q)realpath:a}`
# (Q) removes a level of quoting, :a converts it to an absolute path

# =========================
# KEYBIND TO SWITCH GROUP
# =========================
zstyle ':fzf-tab:*' switch-group '<' '>'

# =========================
# DEFAULT FLAGS FOR FZF WHEN USING FZF-TAB
# =========================
#
# Note: fzf-tab does not use default fzf options
# default_binds=tab:down,btab:up,change:top,ctrl-space:toggle,bspace:backward-delete-char/eof,ctrl-h:backward-delete-char/eof
#
# Note: some other flags are already set in fzf-tab code
# @see https://github.com/Aloxaf/fzf-tab/blob/master/lib/-ftb-fzf#L90
zstyle ':fzf-tab:*' fzf-flags \
  $__FZF_COLORS \
  --height=-2 \
  --preview-window 'right:40%:wrap' \
  --bind 'alt-up:preview-page-up' \
  --bind 'alt-down:preview-page-down' \
  --bind "ctrl-o:execute($VISUAL {})+abort" \
  --bind '?:toggle-preview'

# =========================
# DISABLE OR OVERRIDE PREVIEW FOR COMMAND OPTIONS AND SUBCOMMANDS
# =========================
zstyle ':fzf-tab:complete:*:options' fzf-preview
zstyle ':fzf-tab:complete:*:argument-1' fzf-preview

# =========================
# DESCRIBE COMMANDS WHEN COMPLETING THE COMMAND POSITION
# =========================
# fzf-tab previews are zsh snippets with $word set; `{}` is fzf syntax and isn't substituted.
# The preview runs in a separate zsh, so aliases and functions from this shell are unknown to it.
zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
  'tldr --color always $word 2>/dev/null || whence -va -- $word'

# =========================
# EXPAND THE VALUE OF ENVIRONMENT VARIABLES OR SIMILAR PARAMETERS IN THE PREVIEW WINDOW
# =========================
zstyle ':fzf-tab:complete:(-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'

# =========================
# PREVIEW DIRECTORY OR FILE'S CONTENT WHEN COMPLETING SOME COMMANDS
# =========================
zstyle ':fzf-tab:complete:(cd|vim|nano|e|hx|cursor|code|mv|cp|rm|file):*' \
  fzf-preview "${__FZF_TAB[PREVIEW_FILE_OR_DIR]}"

# =========================
# GIT
# =========================
__FZF_TAB[PREVIEW_DELTA]='delta --hunk-header-decoration-style="cyan box"'
zstyle ':fzf-tab:complete:git-(add|diff|restore|show|checkout):*' fzf-flags \
  $__FZF_COLORS \
  --height=-2 \
  --preview-window 'right:40%:nowrap' \
  --bind 'alt-up:preview-page-up' \
  --bind 'alt-down:preview-page-down'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview "git diff \$word | ${__FZF_TAB[PREVIEW_DELTA]}"
# $group is the formatted description, so it carries the '[%d]' brackets from completions.zsh
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
	'case "$group" in
	"[commit tag]") git show --color=always $word ;;
	*) git show --color=always $word | '"${__FZF_TAB[PREVIEW_DELTA]}"' ;;
	esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
	'case "$group" in
	"[modified file]") git diff $word | '"${__FZF_TAB[PREVIEW_DELTA]}"' ;;
	"[recent commit object name]") git show --color=always $word | '"${__FZF_TAB[PREVIEW_DELTA]}"' ;;
	*) git log --color=always $word ;;
	esac'

zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview 'git help $word | bat -plman --color=always'

# =========================
# HOMEBREW
# =========================
zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-flags \
  $__FZF_COLORS \
  --height=-2 \
  --preview-window 'right:70%:nowrap' \
  --bind 'alt-up:preview-page-up' \
  --bind 'alt-down:preview-page-down'
zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview 'brew info $word | bat --color=always'

# =========================
# KILL / PS
# =========================
zstyle ':fzf-tab:complete:(kill|ps):*' fzf-flags \
  $__FZF_COLORS \
  --height=20 \
  --preview-window 'down:3:wrap'

if [[ "$OSTYPE" = darwin* ]]; then
  zstyle ':completion:*:processes-names' command "ps -wwrcau$USER -o comm | uniq" # killall
  zstyle ':completion:*:*:*:*:processes' command "ps -wwrcau$USER -o pid,user,comm"
  zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
    '[[ $group == "[process ID]" ]] && ps -wwp$word -o comm='
elif [[ "$OSTYPE" = linux* ]]; then
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
  zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
    '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'

  # systemd
  zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
fi

unset __FZF
unset __FZF_TAB
unset __FZF_COLORS

