# op.zsh - 1Password credential helpers for shell session
# Uses `op run` to inject secrets from 1Password when running commands

# Generic function to get credentials from 1Password
# Usage: opkey <op-path>
opkey() {
  op read "$1"
}

# Run a command with OpenAI API key
# Usage: with_openai <command>
with_openai() {
  export OPENAI_API_KEY='op://Private/OpenAI API Key/api key'
  op run -- "$@"
}

# Run a command with OpenRouter API key
# Usage: with_openrouter <command>
with_openrouter() {
  export OPENROUTER_KEY='op://Private/OpenRouter API Key/credential'
  export OPENROUTER_API_KEY='op://Private/OpenRouter API Key/credential'
  op run -- "$@"
}

# Run a command with Google/Gemini API key
# Usage: with_gemini <command>
with_gemini() {
  export GOOGLE_API_KEY='op://Private/Google AI API Key/credential'
  op run -- "$@"
}

# Run a command with Resend API key
# Usage: with_resend <command>
with_resend() {
  export RESEND_API_KEY='op://Private/Resend API Key/credential'
  op run -- "$@"
}

# Run a command with all LLM API keys (OpenAI + OpenRouter + Gemini)
# Usage: with_llm <command>
with_llm() {
  export OPENAI_API_KEY='op://Private/OpenAI API Key/api key'
  export OPENROUTER_KEY='op://Private/OpenRouter API Key/credential'
  export OPENROUTER_API_KEY='op://Private/OpenRouter API Key/credential'
  export GOOGLE_API_KEY='op://Private/Google AI API Key/credential'
  op run -- "$@"
}
