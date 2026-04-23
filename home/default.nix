# Shared home base used by all hosts (macOS and NixOS).
# Hosts import this and add their own packages/programs on top.

{ pkgs, currentSystemUser, ... }:

{
  imports = [
    ./programs/atuin.nix
    ./programs/delta.nix
    ./programs/direnv.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/helix.nix
    ./programs/htop.nix
    ./programs/lazygit.nix
    ./programs/starship.nix
    ./programs/yazi.nix
    ./programs/zoxide.nix
    ./programs/trippy.nix
    ./programs/zsh.nix
  ];

  xdg.enable = true;
  manual.manpages.enable = false;

  home.stateVersion = "25.05";
  home.username = currentSystemUser;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${currentSystemUser}" else "/home/${currentSystemUser}";

  home.packages = with pkgs; [
    # ── Networking & security ──────────────────────────────────────────────
    curl
    xh
    mosh
    autossh
    knot-dns # kdig
    bandwhich # network bandwidth monitor by process
    nmap
    socat
    iperf
    trippy # traceroute TUI (t/tu functions)
    wireguard-tools
    testssl
    sslscan
    tcping-go

    # ── File operations ────────────────────────────────────────────────────
    bat
    eza
    rsync
    fd
    ripgrep # file/content search
    vivid # LS_COLORS (colors.zsh)
    dust # du in Rust
    hexyl # hex viewer
    difftastic
    delta # better diffs
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
    progress
    pv # progress bars
    zsh-completions

    # ── Data & text ────────────────────────────────────────────────────────
    jq
    yq-go
    fx # JSON/YAML
    miller
    gron # data processing
    sd
    choose # modern sed/cut
    gnugrep # grep (for zsh alias)
    jo # generate JSON

    # ── Version control ────────────────────────────────────────────────────
    git
    git-lfs
    git-extras

    # ── Developer tools ────────────────────────────────────────────────────
    nh # Nix helper
    uv # Python package manager

    # ── Documentation & misc ──────────────────────────────────────────────
    tldr
    cht-sh
    fastfetch # system info
  ];
}
