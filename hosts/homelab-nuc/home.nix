{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    # Shell programs
    ../../home/programs/atuin.nix
    ../../home/programs/delta.nix
    ../../home/programs/direnv.nix
    ../../home/programs/fzf.nix
    ../../home/programs/git.nix
    ../../home/programs/helix.nix
    ../../home/programs/htop.nix
    ../../home/programs/lazygit.nix
    ../../home/programs/starship.nix
    ../../home/programs/yazi.nix
    ../../home/programs/zoxide.nix
    ../../home/programs/zsh.nix
  ];

  home.username = "ale";
  home.homeDirectory = "/home/ale";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    # ── Networking & security ──────────────────────────────────────────────
    curl xh mosh autossh
    knot-dns # kdig (modern dig; used in dns() function)
    bandwhich # network bandwidth monitor by process
    nmap socat iperf
    trippy # traceroute TUI (t/tu functions)
    wireguard-tools
    testssl sslscan
    magic-wormhole croc # p2p file transfer
    tcping-go

    # ── File operations ────────────────────────────────────────────────────
    bat eza rsync
    fd ripgrep silver-searcher # file/content search
    vivid # LS_COLORS (colors.zsh)
    dust # du in Rust
    hexyl # hex viewer
    difftastic delta # better diffs
    moreutils # ts, sponge, etc.
    lesspipe # LESSOPEN handler
    entr # run commands on file change
    ncdu # disk usage TUI

    # ── System monitoring ──────────────────────────────────────────────────
    bottom # btm
    duf # disk usage/free
    procs # modern ps
    glances # system monitor

    # ── Shell & terminal ───────────────────────────────────────────────────
    tmux
    glow # render Markdown
    progress pv # progress bars
    zsh-completions
    zsh-fast-syntax-highlighting # sourced by zsh.nix

    # ── Data & text ────────────────────────────────────────────────────────
    jq yq-go fx # JSON/YAML
    miller gron # data processing
    sd choose # modern sed/cut
    gnugrep # grep (for zsh alias)
    jo # generate JSON

    # ── Developer tools ────────────────────────────────────────────────────
    just
    git git-lfs git-extras git-open
    gh # GitHub CLI
    nh # Nix helper
    uv # Python package manager
    emojify # used in git log pager

    # ── Nix tooling ────────────────────────────────────────────────────────
    nil # Nix LSP
    yaml-language-server

    # ── Documentation & misc ──────────────────────────────────────────────
    tldr cht-sh
    fastfetch # system info
  ];
}
