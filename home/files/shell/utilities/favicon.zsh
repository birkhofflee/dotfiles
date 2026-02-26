#!/usr/bin/env zsh

set -euo pipefail

# Generate a favicon.ico with 4 sizes (16x16, 32x32, 48x48, 64x64) from an image.
# Usage: favicon <input_image>
if [ $# -ne 1 ]; then
  echo "Usage: favicon <input_image>"
  exit 1
fi

convert "$1" -background white \
  \( -clone 0 -resize 16x16 -extent 16x16 \) \
  \( -clone 0 -resize 32x32 -extent 32x32 \) \
  \( -clone 0 -resize 48x48 -extent 48x48 \) \
  \( -clone 0 -resize 64x64 -extent 64x64 \) \
  -delete 0 -alpha off -colors 256 favicon.ico
