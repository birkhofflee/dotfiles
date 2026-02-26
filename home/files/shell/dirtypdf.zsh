#!/usr/bin/env zsh

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: dirtypdf <input_pdf> <output_pdf>"
  exit 1
fi

input_file="$1"
output_file="$2"

if [ ! -f "$input_file" ]; then
  echo "Error: Input file '$input_file' does not exist"
  exit 1
fi

# Apply scanner effect to a PDF
# https://gist.github.com/andyrbell/25c8632e15d17c83a54602f6acde2724
# https://github.com/NixOS/nixpkgs/issues/138638#issuecomment-1068569761
nix-shell --packages 'imagemagickBig' --run "magick -density 90 \"$input_file\" -rotate 0.5 -attenuate 0.2 +noise Multiplicative -colorspace Gray \"$output_file\""

# Open the output file in file manager
if [[ "$OSTYPE" == darwin* ]]; then
  open -R "$output_file"
elif command -v xdg-open &> /dev/null; then
  xdg-open "$(dirname "$output_file")"
else
  echo "Output saved to: $output_file"
fi
