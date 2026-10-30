#!/usr/bin/env zsh

# `functions.zsh` provides helper functions and utilities.

function install_ssh_key {
  # Add SSH pubkey and make sure pubkey auth is enabled
  ssh-add -L | grep "id_ed25519" | ssh "$1" "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo >> ~/.ssh/authorized_keys && cat >> ~/.ssh/authorized_keys && chmod  600 ~/.ssh/authorized_keys && (grep -qE '^#?PubkeyAuthentication' /etc/ssh/sshd_config && sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/'               /etc/ssh/sshd_config || echo 'PubkeyAuthentication yes' | tee -a /etc/ssh/sshd_config) && systemctl restart sshd"

  # Add Ghostty terminfo
  # @see https://ghostty.org/docs/help/terminfo#ssh
  infocmp -x xterm-ghostty | ssh "$1" -- tic -x -
}

# Send a notification through the terminal app
# using OSC 777
function notify_osc777() {
    local title="$1"
    local body="$2"
    printf '\e]777;notify;%s;%s\a' "$title" "$body"
}

# Output the image data in clipboard to stdout.
# @example impaste > /tmp/image.png
function impaste {
  if [[ "$OSTYPE" == darwin* ]]; then
    pngpaste -
  elif command -v xclip &> /dev/null; then
    # Linux with X11: use xclip
    if xclip -selection clipboard -t image/png -o 2>/dev/null; then
      return 0
    else
      echo "image read failed" >&2
      return 1
    fi
  elif command -v wl-paste &> /dev/null; then
    # Linux with Wayland: use wl-paste
    if wl-paste --type image/png 2>/dev/null; then
      return 0
    else
      echo "image read failed" >&2
      return 1
    fi
  else
    echo "image read failed" >&2
    return 1
  fi
}

# Timer from terminal with a notification on completion
function timer {
  if [[ "$OSTYPE" == darwin* ]]; then
    # macOS: use terminal-notifier
    command termdown "$@" && terminal-notifier -message "Time's up" -title "Termdown" -ignoreDnD -group termdown -sound Glass
  elif command -v notify-send &> /dev/null; then
    # Linux: use notify-send
    command termdown "$@" && notify-send -u normal "Termdown" "Time's up"
  else
    echo "Error: timer requires terminal-notifier (macOS) or notify-send (Linux)" >&2
    return 1
  fi
}

# Clone repo and cd into it
function gg {
  git clone --depth 1 "$1" && cd "$(basename "$1" .git)"
}

# Wrapper around https://github.com/simonw/llm
# Plugins are packaged together with Nix (see home/default.nix)
function _llm {
  with_llm command llm "$@"
}

# Render the Markdown output with glow (https://github.com/charmbracelet/glow)
# This has no streaming support (have to wait until the model finishes generating)
function llm {
  _llm "$@" | glow -
}

# Read the image from clipboard, convert it to Markdown using
# a system prompt template, and copy the Markdown result
# while rendering it to the terminal.
#
# @see https://gist.github.com/birkhofflee/45f6dab957557469a5bef19be236dc65
function md {
  emulate -L zsh
  setopt LOCAL_OPTIONS PIPE_FAIL

  # Use a temporary file to preserve binary data
  local temp_file=$(mktemp)
  trap "rm -f '$temp_file'" EXIT

  # Get input and save to temp file
  if ! impaste > "$temp_file"; then
    echo "Error: Failed to get clipboard image" >&2
    return 1
  fi

  if [[ ! -s "$temp_file" ]]; then
    echo "Error: No input image received from clipboard" >&2
    return 1
  fi

  # Process through LLM and display
  if ! cat "$temp_file" | _llm --template md -a - | tee >(pbcopy) >(glow -) > /dev/null; then
    echo "Error: Conversion failed" >&2
    return 1
  fi

  # Success notification
  terminal-notifier \
    -message "Conversion Complete" \
    -title "md" \
    -ignoreDnD \
    -group md \
    -sound Hero &>/dev/null # Don't show message of removal of previous notification

  return 0
}

# Use `llm` to generate a conventional commit draft using cached diff
function aic {
  echo "Working..."

  git commit -F <(git diff --cached | llm -s "Write a commit message in the Conventional Commits format. Use the structure:
  <type>(<optional scope>): <short description>

  <optional body>

  <optional footer>

  Example types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
  Optionally, include a body for more details in bullet points.
  Optionally, in the footer, use BREAKING CHANGE: followed by a detailed explanation of the breaking change.

  Just return the commit message, do not include any other text.") -e
}

function take {
  [[ -n "$1" ]] && mkdir -p "$1" && builtin cd "$1"
}

function tt {
  builtin cd $(mktemp -d)
}

# Changes to a directory and lists its contents.
function cdls {
  builtin cd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# e: edit with default editor or open cwd with editor
function e {
  if [[ ! -z $1 ]]; then
    $VISUAL $1
  else
    # file=$(__fsel); [[ ! -z $file ]] && $VISUAL $file
    # # __fsel is the actual selector function used by fzf-file-widget
    $VISUAL .
  fi
}

# Update geoip.mmdb if it's older than 7 days
# @see https://github.com/Loyalsoldier/geoip#maxmind-mmdb-下载地址
function _update_geoip {
  local _geoip_cache="${XDG_CACHE_HOME:-$HOME/.cache}/geoip.mmdb"
  if [ ! -f "$_geoip_cache" ] || [ $(find "$_geoip_cache" -mtime +7 2>/dev/null | wc -l) -gt 0 ]; then
    wget -O "$_geoip_cache" https://fastly.jsdelivr.net/gh/Loyalsoldier/geoip@release/Country-without-asn.mmdb
  fi
}

# Traceroute with Trippy
function t {
  _update_geoip

  # Config is managed by home-manager
  sudo trip -c $XDG_CONFIG_HOME/trippy/trippy.toml "$@"
}

# UDP Traceroute with Trippy
# @see https://trippy.rs/guides/recommendation/#udpdublin-with-fixed-target-port-and-variable-source-port
function tu {
  _update_geoip

  # Config is managed by home-manager
  sudo trip \
    -c $XDG_CONFIG_HOME/trippy/trippy.toml \
    --udp \
    --multipath-strategy dublin \
    --target-port 33434 \
    --tui-custom-columns holavbwdtSPQ \
    "$@"
}

# Show TLS certificate details for a given domain
# @note     use testssl.sh for complete analysis
# @example  `https google.com 443`
function https {
  local port=${2:-443}
  echo | openssl s_client -showcerts -servername $1 -connect $1:$port 2>/dev/null | openssl x509 -inform pem -noout -text
}

# Measure TTFB (Time To First Byte)
# https://gist.github.com/sandeepraju/1f5fbdbdd89551ba7925abe2645f92b5
# @example  `ttfb google.com`
function ttfb {
  curl -Is \
    -H 'Cache-Control: no-cache' \
    -w "Connect: %{time_connect}s TTFB: %{time_starttransfer}s Total time: %{time_total}s\n" \
    "$@"
}

# List all processes listening on a port
function listening {
  if [ $# -eq 0 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P
  elif [ $# -eq 1 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
  else
    echo "Usage: listening [pattern]"
  fi
}

# ping until success or cancelled
function pingu {
  local ping_cancelled
  ping_cancelled=false    # Keep track of whether the loop was cancelled, or succeeded
  until ping -c1 "$1" >/dev/null 2>&1; do :; done &    # The "&" backgrounds it
  trap "kill $!; ping_cancelled=true" SIGINT
  wait $!          # Wait for the loop to exit, one way or another
  trap - SIGINT    # Remove the trap, now we're done with it
  echo "Done pinging, cancelled=$ping_cancelled"
}

# Lookup an IP address
function lip {
  xhs -b api.birkhoff.me/v3/ip/$1
}

# Lookup certificate transparency logs for an apex domain
function crt-lookup {
  xhs "https://crt.name/v1/search?apex=$1"
}

# Lookup IP address of an A record of a domain
function dns {
  lip $(kdig @8.8.4.4 +short $1 | tail -n1)
}

# Example:
# $ nix-pkgdir paho-mqtt-c
# /nix/store/92h4cbrnnxcmqvdzzkdyajfm3b6yvf13-paho.mqtt.c-1.3.12
function nix-pkgdir {
  nix eval -f '<nixpkgs>' --raw $1
}

# Run a nix package from nixpkgs unstable
# @example  `nr paho-mqtt-c`
function nr {
  NIXPKGS_ALLOW_UNFREE=1 nix run --impure "github:NixOS/nixpkgs/nixpkgs-unstable#$1" -- "${@:2}"
}

alias nru=nr

# Get a shell for a nix package from nixpkgs
# @example  `ns paho-mqtt-c cowsay curl`
# @see https://discourse.nixos.org/t/nix-shell-does-not-use-my-users-shell-zsh/5588/19
function ns {
  if [ $# -eq 0 ]; then
    echo "Usage: ns package1 package2 package3 ..."
    return 1
  fi

  extension=""

  for pkg in "$@"; do
    extension="$extension github:NixOS/nixpkgs/nixpkgs-unstable\#$pkg"
  done

  cmd="nix shell$extension"

  # Print the actual command in bold
  printf "\033[1m%s\033[0m\n" "$cmd"
  eval "$cmd"
}

# Download a media (yt-dlp) or a generic file (wget/curl)
function get {
  local url="$1"

  # Check if URL looks like a media site yt-dlp handles well
  if command -v yt-dlp > /dev/null && [[ "$url" =~ (youtube\.com|youtu\.be|vimeo\.com|twitch\.tv|twitter\.com|instagram\.com|tiktok\.com) ]]; then
    yt-dlp --continue --progress "$@"
  elif command -v curl > /dev/null; then
    curl --continue-at - --location --progress-bar --remote-name --remote-time "$@"
  elif command -v wget > /dev/null; then
    wget --continue --progress=bar --timestamping "$@"
  else
    echo "curl/wget not found"
  fi
}

# Copy a PDF page to clipboard as PNG
# @example  `pdfcopypage document.pdf 0`
function pdfcopypage {
  if [[ $# -ne 2 || ! -f "$1" ]]; then
    echo "Usage: pdfcopypage <file.pdf> <page>" >&2
    return 1
  fi
  # https://stackoverflow.com/a/6605085
  magick -density 150 "$1[$2]" -trim -quality 100 -flatten -sharpen 0x1.0 jpg:- | impbcopy -
}

# Grep using ripgrep and run enhancements on outputs
# using delta
function s {
  rg --json -C 5 $1 | delta
}

# Upload a file to B2 and return a presigned URL via download.birkhoff.me
function b2upload() {
  if [[ -z "$1" ]]; then
    echo "usage: b2upload <file> [expiry: 1h, 2h, ..., 1d, ..., 7d]" >&2
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "b2upload: not a file: $1" >&2
    return 1
  fi

  local EXPIRY="${2:-1h}"
  local EXPIRY_SECONDS
  if [[ "$EXPIRY" =~ '^([0-9]+)([hd])$' ]]; then
    local num="${match[1]}" unit="${match[2]}"
    if [[ "$unit" == "h" ]]; then
      EXPIRY_SECONDS=$(( num * 3600 ))
    else
      if (( num < 1 || num > 7 )); then
        echo "b2upload: days must be 1–7" >&2
        return 1
      fi
      EXPIRY_SECONDS=$(( num * 86400 ))
    fi
  else
    echo "b2upload: invalid expiry '$EXPIRY' (use e.g. 1h, 2h, 1d, 7d)" >&2
    return 1
  fi

  local -x AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_ENDPOINT_URL AWS_DEFAULT_REGION
  AWS_ACCESS_KEY_ID=$(op read "op://Private/B2 Application Key/keyID") || return 1
  AWS_SECRET_ACCESS_KEY=$(op read "op://Private/B2 Application Key/applicationKey") || return 1
  AWS_ENDPOINT_URL=https://s3.us-west-002.backblazeb2.com
  AWS_DEFAULT_REGION=us-west-002

  local BUCKET_NAME=assets-birkhoff-private
  local FILENAME=$(basename "$1")

  command aws s3 cp "$1" "s3://$BUCKET_NAME/$FILENAME" || return 1

  URL=$(command aws s3 presign "s3://$BUCKET_NAME/$FILENAME" --expires-in "$EXPIRY_SECONDS")

  echo "${URL/$BUCKET_NAME.s3.us-west-002.backblazeb2.com/download.birkhoff.me}"
}

