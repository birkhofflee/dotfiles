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

# fzf-tab previews run in zsh. Use [[ ]]: with an empty $realpath (non-file items such as
# named directories or options), `[ -d $realpath ]` is `[ -d ]`, which is true.
__FZF_TAB[PREVIEW_FILE_OR_DIR]="
  if [[ -d \$realpath ]]; then
    ${__FZF[PREVIEW_DIR]} \$realpath;
  elif [[ -f \$realpath ]]; then
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
# ^O: open the selected items with $VISUAL
export FZF_DEFAULT_OPTS="
  ${__FZF_COLORS[*]}
  --style full
  --multi
  --bind 'alt-up:preview-page-up'
  --bind 'alt-down:preview-page-down'
  --bind 'ctrl-o:execute(\$VISUAL {+})+abort'
  --bind '?:toggle-preview'
"

# Only for the widgets below; FZF_DEFAULT_OPTS reaches every program that runs fzf.
__FZF[HEADER]="--header '?: preview, alt-up: pgup, alt-down: pgdown, ^o: open editor'"

# =========================
# FZF - File Browser (C-t) and Alt-C
# Override FZF_CTRL_T_COMMAND and FZF_ALT_C_COMMAND to use fd
# =========================
#
# fd's output is piped straight into fzf so results stream in as they're found.
# (Sorting by mtime via `xargs ls -t` made fzf wait for the whole walk, and xargs
# batching meant the order was only correct within each batch.)
#
# Explanation of the options:
# -tf: only regular files
# -td: only directories
# --follow: follow symlinks
# -H: include hidden files
exclude_list=(
  "--exclude .git"
  "--exclude .direnv"
  "--exclude node_modules"
  "--exclude .DS_Store"
)
export FZF_CTRL_T_COMMAND="fd -H -tf --follow ${exclude_list[*]}"
export FZF_ALT_C_COMMAND="fd -td ${exclude_list[*]}"
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
#
# No ^O here: fzf-tab's lines are `index\0display\0…`, and the display is relative
# to the completion prefix, so no placeholder yields a usable path.
zstyle ':fzf-tab:*' fzf-flags \
  $__FZF_COLORS \
  --height=-2 \
  --preview-window 'right:40%:wrap' \
  --bind 'alt-up:preview-page-up' \
  --bind 'alt-down:preview-page-down' \
  --bind '?:toggle-preview'

# =========================
# DISABLE PREVIEW FOR COMMAND OPTIONS
# =========================
# No catch-all for argument-1: on equal specificity the first-defined zstyle wins, so an
# empty `*:argument-1` here hid later previews for first arguments, e.g. git-log:*.
zstyle ':fzf-tab:complete:*:options' fzf-preview

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
zstyle ':fzf-tab:complete:(cd|vim|nano|e|hx|cursor|code|mv|cp|rm|rmdir|ln|file|bat|cat|less|head|tail|open|eza|ls|ncdu|source):*' \
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
# git diff is empty for untracked files, so show their contents instead
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview "
  if [[ \$group == '[untracked file]' ]]; then
    if [[ -d \$word ]]; then ${__FZF[PREVIEW_DIR]} \$word; else less \$word; fi
  else
    git diff \$word | ${__FZF_TAB[PREVIEW_DELTA]}
  fi
"
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
# MAN
# @see https://github.com/Freed-Wu/fzf-tab-source/blob/main/sources/man.zsh
# =========================
# With separate-sections (completions.zsh) the group is "[manual page, section N]".
# macOS man already emits ANSI formatting when piped, so no bat.
zstyle ':fzf-tab:complete:man:*' fzf-preview \
  '[[ $group == "[manual page"* ]] && MANWIDTH=$FZF_PREVIEW_COLUMNS man $word 2>/dev/null'

# =========================
# DOCKER
# @see https://github.com/Freed-Wu/fzf-tab-source/blob/main/sources/docker.zsh (and docker-*.zsh)
# =========================
# OrbStack's cobra-generated _docker never sets per-subcommand contexts (no docker-inspect:
# etc.), so everything arrives as `docker:` and the preview branches on $words instead.
zstyle ':fzf-tab:complete:docker:*' fzf-preview \
	'if (( $#words <= 2 )); then
		docker $word --help
	elif (( $#words == 3 )) && [[ $words[2] == (container|image|network|volume|compose|system|context|buildx) ]]; then
		docker $words[2] $word --help
	else
		case $words[2] in
		(logs) docker logs --tail 100 $word 2>&1 ;;
		(run|create|rmi|history|tag|push|pull|save) docker images $word ;;
		(*) docker inspect $word 2>/dev/null | bat -ljson -p --color=always ;;
		esac
	fi'

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

