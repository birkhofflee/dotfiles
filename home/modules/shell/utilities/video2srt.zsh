#!/bin/zsh

set -euo pipefail

export OPENAI_API_URL=https://openrouter.ai/api/v1
export OPENAI_API_KEY=$(op read 'op://Private/OpenRouter API Key/credential')
export OPENAI_MODEL=google/gemini-3-flash-preview

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Temporary directory for intermediate files
TMPDIR=$(mktemp -d)

# Cleanup function
cleanup() {
    local exit_code=$?
    if [[ -d "$TMPDIR" ]]; then
        echo "${YELLOW}Cleaning up temporary files...${NC}"
        rm -rf "$TMPDIR"
        echo "  Removed: $TMPDIR"
    fi
    if [[ $exit_code -ne 0 ]]; then
        echo "${RED}Script failed with exit code $exit_code${NC}"
    fi
}

# Set up trap for cleanup
trap cleanup EXIT INT TERM

# Error handler
error_exit() {
    echo "${RED}Error: $1${NC}" >&2
    exit 1
}

# Check arguments
if [[ $# -ne 1 ]]; then
    error_exit "Usage: $0 <input.mp4>"
fi

INPUT_MP4="$1"

# Check if input file exists
if [[ ! -f "$INPUT_MP4" ]]; then
    error_exit "Input file does not exist: $INPUT_MP4"
fi

# Check if input is an mp4 file
if [[ ! "$INPUT_MP4" =~ \.mp4$ ]]; then
    error_exit "Input file must be an MP4 file: $INPUT_MP4"
fi

# Get basename without extension
BASENAME="${INPUT_MP4:r:t}"
WAV_FILE="$TMPDIR/${BASENAME}.wav"
SRT_FILE="${BASENAME}.srt"
JSON_FILE="${BASENAME}.json"
PROCESSED_SRT="${BASENAME}.processed.srt"

echo "${GREEN}Starting video to subtitle conversion...${NC}"
echo "Input: $INPUT_MP4"
echo ""

# Step 1: Convert MP4 to WAV
echo "${GREEN}[1/3] Converting MP4 to WAV...${NC}"
if ! ffmpeg -i "$INPUT_MP4" -ac 2 -f wav "$WAV_FILE"; then
    error_exit "Failed to convert MP4 to WAV"
fi
echo "${GREEN}✓ WAV file created: $WAV_FILE${NC}"
echo ""

# Step 2: Run parakeet-mlx to generate SRT
echo "${GREEN}[2/3] Running parakeet-mlx for transcription...${NC}"
if ! uv tool run parakeet-mlx "$WAV_FILE" --max-words 15; then
    error_exit "Failed to run parakeet-mlx"
fi
if [[ ! -f "$SRT_FILE" ]]; then
    error_exit "Expected SRT file not found: $SRT_FILE"
fi
echo "${GREEN}✓ SRT file created: $SRT_FILE${NC}"
echo ""

# Step 3: Post-process SRT file with srt-llm-processor
echo "${GREEN}[3/3] Post-processing SRT file with LLM...${NC}"
if ! nix run github:BirkhoffLee/srt-llm-processor -- --file "$SRT_FILE"; then
    error_exit "Failed to post-process SRT file"
fi
echo "${GREEN}✓ Processed SRT file created: $PROCESSED_SRT${NC}"
echo ""

