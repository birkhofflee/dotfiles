#!/usr/bin/env zsh

# Credits:
# https://github.com/Aloxaf/dotfiles/blob/0619025cb2c2264cd0639b3697e3483454b2cadd/zsh/.config/zsh/snippets/completion.zsh

setopt COMPLETE_IN_WORD # autocomplete in middle of a word
setopt NO_BEEP # disable beep sound
setopt AUTO_PARAM_SLASH # (autocomplete) If completed parameter is a directory, add a trailing slash
unsetopt MENU_COMPLETE # Do not autoselect the first completion entry

# Use new completion system
zstyle ':completion:*' use-compctl false
compctl () { }

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*:complete:*' cache-policy _COMP_CACHING_POLICY
_COMP_CACHING_POLICY() {
  # If cache don't exist or are older than 14 days, consider them invalid
  [[ ! -f $1 && -n "$1"(Nm+14) ]]
}

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
  clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
  gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
  ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
  operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
  usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# Dynamically set the order of completion functions (completers) for Zsh.
# On the first TAB press, only fast and common completers are used for performance:
#   - _expand_alias: expand aliases
#   - _complete: standard completion
#   - _extensions: complete file extensions (*.\t)
#   - _match: allow wildcard matching
#   - _files: file completion
# If the user presses TAB again (without changing the command), slower or more permissive completers are added:
#   - _ignored: include previously ignored matches by ignored-patterns
#   - _correct: offer spelling corrections
#   - _approximate: offer fuzzy/approximate matches
# This setup ensures fast completions on the first try, and more exhaustive/fuzzy completions only on repeated attempts, improving both speed and usability.
#
zstyle -e ':completion:*' completer '
  if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]]; then
    _last_try="$HISTNO$BUFFER$CURSOR"
    reply=(_expand_alias _complete _extensions _match _files)
  else
    reply=(_complete _ignored _correct _approximate)
  fi'

# Enhanced filename completion
# 0 - Exact match ( Abc -> Abc )      1 - Case correction ( abc -> Abc )
# 2 - Word completion ( f-b -> foo-bar )  3 - Suffix completion ( .cxx -> foo.cxx )
zstyle ':completion:*:(argument-rest|files):*' matcher-list '' \
    'm:{[:lower:]-}={[:upper:]_}' \
    'r:|[.,_-]=* r:|=*' \
    'r:|.=* r:|=*'

# Do not complete regular shell aliases
zstyle ':completion:*' regular false

# set list-colors to enable filename colorizing
# LS_COLORS is set in external.zsh
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# Set descriptions format to enable options to be grouped into "completion groups"
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'

zstyle ':completion:*' list-separator ''
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:warnings' format '%F{red}%B-- No match for: %d --%b%f'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'

# 补全当前用户所有进程列表
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':completion:*:kill:*' ignored-patterns '0'

function kubectl() {
  if ! type __start_kubectl >/dev/null 2>&1; then
    source <(command kubectl completion zsh)
  fi

  command kubectl "$@"
}

# complete manual by their section, from grml
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true

# Docker: Short-option stacking can be enabled
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# fg/bg 补全时使用 jobs id
zstyle ':completion:*:jobs' verbose true
zstyle ':completion:*:jobs' numbers true

# disable sort when completing `git checkout`
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:exa' sort false
zstyle ':completion:*:docker' sort false
zstyle ':completion:files' sort false
