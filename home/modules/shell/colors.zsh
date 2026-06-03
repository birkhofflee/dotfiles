#!/usr/bin/env zsh

# LS_COLORS
# https://github.com/sharkdp/vivid?tab=readme-ov-file#usage
# Cache vivid output to avoid regenerating on every shell start
_vivid_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/ls_colors"
if [[ ! -f "$_vivid_cache" ]] || [[ "$(command -v vivid)" -nt "$_vivid_cache" ]]; then
  mkdir -p "${_vivid_cache:h}"
  vivid generate catppuccin-macchiato > "$_vivid_cache"
fi
export LS_COLORS="$(<$_vivid_cache)"
unset _vivid_cache

# grep colors
export GREP_COLOR='1;32'                        # BSD — bold green (match text)
export GREP_COLORS="mt=1;32:fn=35:ln=33:se=36"  # GNU — mt: match, fn: filename, ln: line number, se: separator

# Colored man pages — hardcoded ANSI sequences (avoids 15 tput subprocess forks, saves ~29ms)
# Equivalent tput commands are noted inline for reference
export LESS_TERMCAP_md=$'\e[1;31m'   # tput bold; tput setaf 1  (bold red — headings)
export LESS_TERMCAP_me=$'\e[0m'      # tput sgr0                (reset)
export LESS_TERMCAP_mb=$'\e[1;32m'   # tput bold; tput setaf 2  (bold green — blinking)
export LESS_TERMCAP_us=$'\e[1;32m'   # tput bold; tput setaf 2  (bold green — underline)
export LESS_TERMCAP_ue=$'\e[0m'      # tput rmul; tput sgr0     (underline end)
export LESS_TERMCAP_so=$'\e[1;33;44m' # tput bold; tput setaf 3; tput setab 4  (bold yellow on blue — search)
export LESS_TERMCAP_se=$'\e[0m'      # tput rmso; tput sgr0     (standout end)
