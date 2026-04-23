{ pkgs, ... }:

{
  imports = [
    ../../home
    ../../home/programs/1password.nix
    ../../home/programs/ghostty.nix
  ];

  home.packages = with pkgs; [
    # ── Shell & terminal ───────────────────────────────────────────────────
    glow # render Markdown

    # ── Developer tools ────────────────────────────────────────────────────
    just
    git-open # `git open` to open the GitHub page
    gh # GitHub CLI

    # ── Nix tooling ────────────────────────────────────────────────────────
    nil # Nix LSP
    yaml-language-server

    # ── Desktop utilities ──────────────────────────────────────────────────
    libnotify # provides notify-send (required by zsh-auto-notify)
    xdg-utils
    firefox
  ];
}
