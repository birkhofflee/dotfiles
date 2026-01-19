#!/usr/bin/env zsh

# `functions.zsh` provides helper functions and utilities.

function burnsrt {
  if [[ $# -ne 3 || ! -f "$1" || "${1##*.}" != "mp4" || ! -f "$2" || "${2##*.}" != "srt" || "${3##*.}" != "mp4" ]]; then
    echo "Usage: burnsrt <input.mp4> <input.srt> <output.mp4>" >&2
    echo "  - <input.mp4>: Path to a valid MP4 video file." >&2
    echo "  - <input.srt>: Path to a valid SRT subtitle file." >&2
    echo "  - <output.mp4>: Path for the output MP4 file." >&2
    return 1
  fi

  ffmpeg -i "$1" -f srt -i "$2" -map 0:0 -map 0:1 -map 1:0 -c:v copy \
    -c:a copy -c:s mov_text "$3"
}

function shrinkvid {
  if [ $# -lt 2 ]; then
    echo "Usage: shrinkvid <input_file> <output_file> [bitrate]"
    echo "Example: shrinkvid input.mp4 output.mp4 5M"
    echo "Bitrate: 2M-10M recommended, default is 5M (higher = better quality)"
    if [[ "$OSTYPE" == darwin* ]]; then
      echo "Uses hardware acceleration (VideoToolbox) on Apple Silicon"
    else
      echo "Uses software encoding (libx264) on Linux"
    fi
    return 1
  fi

  # Helper function to convert bytes to human-readable format (using decimal units like eza)
  human_readable() {
    awk -v bytes="$1" 'BEGIN {
      if (bytes >= 1000000000)
        printf "%.1f GB", bytes/1000000000
      else if (bytes >= 1000000)
        printf "%.1f MB", bytes/1000000
      else if (bytes >= 1000)
        printf "%.1f KB", bytes/1000
      else
        printf "%d B", bytes
    }'
  }

  # Get file size (use macOS native stat, not GNU stat)
  get_size() {
    /usr/bin/stat -f%z "$1" 2>/dev/null || stat --format=%s "$1" 2>/dev/null
  }

  # Get input file size
  local input_size=$(get_size "$1")

  # Run ffmpeg with hardware acceleration on macOS, software encoding on Linux
  if [[ "$OSTYPE" == darwin* ]]; then
    ffmpeg -i "$1" -c:v h264_videotoolbox -b:v "${3:-5M}" -tag:v avc1 -movflags faststart "$2"
  else
    ffmpeg -i "$1" -c:v libx264 -b:v "${3:-5M}" -movflags faststart "$2"
  fi

  # Check if ffmpeg succeeded and output file exists
  if [ $? -eq 0 ] && [ -f "$2" ]; then
    local output_size=$(get_size "$2")
    local saved_bytes=$((input_size - output_size))
    local compression_ratio=$(awk -v input="$input_size" -v output="$output_size" 'BEGIN {
      if (input > 0)
        printf "%.2f", (input - output) / input * 100
      else
        printf "0.00"
    }')

    echo ""
    echo "Compression complete:"
    echo "  Input:  $(human_readable $input_size)"
    echo "  Output: $(human_readable $output_size)"
    echo "  Saved:  $(human_readable $saved_bytes) (${compression_ratio}%)"
  fi
}

# Output the image data in clipboard to stdout.
# @example impaste > /tmp/image.png
# @see https://til.simonwillison.net/macos/impaste
function impaste {
  if [[ "$OSTYPE" == darwin* ]]; then
    # macOS: use osascript
    local tempfile=$(mktemp -t clipboard.XXXXXXXXXX.png)
    {
      if osascript -e 'set theImage to the clipboard as «class PNGf»' \
        -e "set theFile to open for access POSIX file \"$tempfile\" with write permission" \
        -e 'write theImage to theFile' \
        -e 'close access theFile' 2>/dev/null; then
        cat "$tempfile"
        return 0
      else
        echo "image read failed" >&2
        return 1
      fi
    } always {
      rm -f "$tempfile"
    }
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
function _llm {
  # uvx --with llm-anthropic llm -m claude-3.5-haiku 'fun facts about skunks'
  # with_llm uvx --with llm-openrouter llm
  #
  # $ uv tool install --with llm-openrouter llm
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
# @see https://gist.github.com/BirkhoffLee/45f6dab957557469a5bef19be236dc65
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

# Decrypt all PDFs in the current directory
# Example: decrypt_pdfs "password"
function decrypt_pdfs {
  local password="$1"
  for file in *.pdf; do
    # Skip if it's not a regular file
    [ -f "$file" ] || continue

    # Check if it's encrypted
    if qpdf --check "$file" 2>&1 | grep -q "is not encrypted"; then
      echo "Already decrypted: $file"
    else
      echo "Decrypting: $file"
      local tmp_file="tmp_decrypted.pdf"
      if qpdf --decrypt --password="$password" "$file" "$tmp_file"; then
        mv "$tmp_file" "$file"
        echo "Decrypted: $file"
      else
        echo "Failed to decrypt: $file"
        rm -f "$tmp_file"
      fi
    fi
  done
}

# Update geoip.mmdb if it's older than 30 days
function _update_geoip {
  if [ ! -f $HOME/.cache/geoip.mmdb ] || [ $(find $HOME/.cache/geoip.mmdb -mtime +30 2>/dev/null | wc -l) -gt 0 ]; then
    wget -O $HOME/.cache/geoip.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb
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
  http -b https://api.birkhoff.me/v3/ip/$1
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

# Apply scanner effect to a PDF
# https://gist.github.com/andyrbell/25c8632e15d17c83a54602f6acde2724
# https://github.com/NixOS/nixpkgs/issues/138638#issuecomment-1068569761
function dirtypdf {
  if [ $# -ne 2 ]; then
    echo "Usage: dirtypdf <input_pdf> <output_pdf>"
    return 1
  fi

  input_file="$1"
  output_file="$2"

  if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' does not exist"
    return 1
  fi

  nix-shell --packages 'imagemagickBig' --run "magick -density 90 \"$input_file\" -rotate 0.5 -attenuate 0.2 +noise Multiplicative -colorspace Gray \"$output_file\""

  # Open the output file in file manager
  if [[ "$OSTYPE" == darwin* ]]; then
    open -R "$output_file"
  elif command -v xdg-open &> /dev/null; then
    xdg-open "$(dirname "$output_file")"
  else
    echo "Output saved to: $output_file"
  fi
}

# `favicon 1.png` will generate 4 sizes of favicon.ico
function favicon {
  convert $1 -background white \
    \( -clone 0 -resize 16x16 -extent 16x16 \) \
    \( -clone 0 -resize 32x32 -extent 32x32 \) \
    \( -clone 0 -resize 48x48 -extent 48x48 \) \
    \( -clone 0 -resize 64x64 -extent 64x64 \) \
    -delete 0 -alpha off -colors 256 favicon.ico
}

# Search in files, then pipe files with 10 line buffer into fzf preview using bat.
# https://github.com/issmirnov/dotfiles/blob/df92f79a760740a7d389605f2f0f5085ca95a713/zsh/config/fzf.zsh#L149-L161
# Notes:
#  - if you want to replace ag for rg feel free (https://blog.burntsushi.net/ripgrep/)
#  - Same goes for bat, although ccat and others are definitely worse
#  - the $ext extraction uses a ZSH specific text globber
function s {
  local margin=5 # number of lines above and below search result.
  local preview_cmd='search={};file=$(echo $search | cut -d':' -f 1 );'
  preview_cmd+="margin=$margin;" # Inject value into scope.
  preview_cmd+='line=$(echo $search | cut -d':' -f 2 );'
  preview_cmd+='tail -n +$(( $(( $line - $margin )) > 0 ? $(($line-$margin)) : 0)) $file | head -n $(($margin*2+1)) |'
  preview_cmd+='bat --paging=never --color=always --style=full --file-name $file --highlight-line $(($margin+1))'
  local full=$(ag --silent "$*" \
    | fzf --no-height --no-reverse --select-1 --exit-0 --preview-window up:$(($margin*2+1)) --preview $preview_cmd)
  local file="$(echo $full | awk -F: '{print $1}')"
  local line="$(echo $full | awk -F: '{print $2}')"
  [ -n "$file" ] && \
    (code -g "$file":$line || $VISUAL "$file" +$line)
}

