#!/usr/bin/env zsh

if [ $# -lt 2 ]; then
  echo "Usage: shrinkvid <input_file> <output_file> [bitrate]"
  echo "Example: shrinkvid input.mp4 output.mp4 5M"
  echo "Bitrate: 2M-10M recommended, default is 5M (higher = better quality)"
  if [[ "$OSTYPE" == darwin* ]]; then
    echo "Uses hardware acceleration (VideoToolbox) on Apple Silicon"
  else
    echo "Uses software encoding (libx264) on Linux"
  fi
  exit 1
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

input_size=$(get_size "$1")

# Run ffmpeg with hardware acceleration on macOS, software encoding on Linux
if [[ "$OSTYPE" == darwin* ]]; then
  ffmpeg -i "$1" -c:v h264_videotoolbox -b:v "${3:-5M}" -tag:v avc1 -movflags faststart "$2"
else
  ffmpeg -i "$1" -c:v libx264 -b:v "${3:-5M}" -movflags faststart "$2"
fi

if [ $? -eq 0 ] && [ -f "$2" ]; then
  output_size=$(get_size "$2")
  saved_bytes=$((input_size - output_size))
  compression_ratio=$(awk -v input="$input_size" -v output="$output_size" 'BEGIN {
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
