#!/usr/bin/env zsh

set -euo pipefail

if [[ $# -ne 3 || ! -f "$1" || "${1##*.}" != "mp4" || ! -f "$2" || "${2##*.}" != "srt" || "${3##*.}" != "mp4" ]]; then
  echo "Usage: burnsrt <input.mp4> <input.srt> <output.mp4>" >&2
  echo "  - <input.mp4>: Path to a valid MP4 video file." >&2
  echo "  - <input.srt>: Path to a valid SRT subtitle file." >&2
  echo "  - <output.mp4>: Path for the output MP4 file." >&2
  exit 1
fi

ffmpeg -i "$1" -f srt -i "$2" -map 0:0 -map 0:1 -map 1:0 -c:v copy \
  -c:a copy -c:s mov_text "$3"
