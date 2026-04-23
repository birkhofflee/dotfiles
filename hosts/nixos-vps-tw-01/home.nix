{ pkgs, currentSystemUser, ... }:

{
  imports = [
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

  home.username = currentSystemUser;
  home.homeDirectory = "/home/${currentSystemUser}";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # ── Networking & security ──────────────────────────────────────────────
    curl xh mosh autossh
    knot-dns # kdig (modern dig; used in dns() function)
    bandwhich # network bandwidth monitor by process
    nmap socat iperf
    trippy # traceroute TUI (t/tu functions)
    wireguard-tools
    testssl sslscan
    tcping-go

    # ── File operations ────────────────────────────────────────────────────
    bat eza rsync
    fd ripgrep # file/content search
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
    git git-lfs git-extras
    nh # Nix helper
    uv # Python package manager

    # ── Documentation & misc ──────────────────────────────────────────────
    tldr cht-sh
    fastfetch # system info
  ];
}
