{ pkgs, ... }:

{
  imports = [
    ../../home
    ../../home/programs/uv.nix
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
  ];
}
