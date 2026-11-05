#!/usr/bin/env zsh

# `llm.zsh` provides helpers around the llm CLI. Sourced by home/modules/llm.nix.

# Wrapper around https://github.com/simonw/llm
# Plugins are packaged together with Nix (see home/modules/llm.nix)
# with_llm comes from op.zsh, which only desktop hosts load. Elsewhere, llm uses
# its own stored keys (`llm keys set`).
function _llm {
  if (( $+functions[with_llm] )); then
    with_llm command llm "$@"
  else
    command llm "$@"
  fi
}

# Render the Markdown output with glow (https://github.com/charmbracelet/glow)
# This has no streaming support (have to wait until the model finishes generating)
function llm {
  _llm "$@" | glow -
}

# macOS only: uses pbcopy and terminal-notifier.
#
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

