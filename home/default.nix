# Shared home base used by all hosts (macOS and NixOS).
# Hosts import this and add their own packages/programs on top.

{
  pkgs,
  currentSystemUser,
  ...
}:

{
  imports = [
    ./modules/ansible.nix
    ./modules/atuin.nix
    ./modules/bat.nix
    ./modules/bottom.nix
    ./modules/claude.nix
    ./modules/codex.nix
    ./modules/delta.nix
    ./modules/direnv.nix
    ./modules/dprint.nix
    ./modules/editorconfig.nix
    ./modules/fzf.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/helix.nix
    ./modules/htop.nix
    ./modules/hushlogin.nix
    ./modules/lazygit.nix
    ./modules/llm.nix
    ./modules/mcp.nix
    ./modules/nano.nix
    ./modules/nodejs.nix
    ./modules/opencode.nix
    ./modules/scripts.nix
    ./modules/ssh.nix
    ./modules/starship.nix
    ./modules/television.nix
    ./modules/trippy.nix
    ./modules/uv.nix
    ./modules/yazi.nix
    # ./modules/zellij.nix
    ./modules/zoxide.nix
    ./modules/zsh.nix
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
    wireguard-tools
    testssl
    sslscan
    tcping-go

    # ── File operations ────────────────────────────────────────────────────
    eza
    rsync
    fd
    ripgrep # file/content search
    vivid # LS_COLORS (colors.zsh)
    dust # du in Rust
    hexyl # hex viewer
    difftastic
    moreutils # ts, sponge, etc.
    lesspipe # LESSOPEN handler
    entr # run commands on file change
    ncdu # disk usage TUI

    # ── System monitoring ──────────────────────────────────────────────────
    duf # disk usage/free
    procs # modern ps
    glances # system monitor

    # ── Shell & terminal ───────────────────────────────────────────────────
    tmux
    progress
    pv # progress bars

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

    # ── Developer tools ────────────────────────────────────────────────────
    nh # Nix helper

    # ── Documentation & misc ──────────────────────────────────────────────
    tldr
    cht-sh
    fastfetch # system info
  ];
}
