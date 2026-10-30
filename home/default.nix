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
    ./modules/btop.nix
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
    ./modules/zoxide.nix
    ./modules/zsh.nix
  ];

  xdg.enable = true;
  manual.manpages.enable = false;

  home.stateVersion = "25.05";
  home.username = currentSystemUser;
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${currentSystemUser}" else "/home/${currentSystemUser}";

  home.packages = with pkgs; [
    # ── Networking & security ──────────────────────────────────────────────
    curl # https://curl.se
    xh # https://github.com/ducaale/xh (modern curl/httpie)
    mosh # https://mosh.org
    autossh # https://www.harding.motd.ca/autossh
    knot-dns # https://www.knot-dns.cz (kdig)
    bandwhich # https://github.com/imsnif/bandwhich (network bandwidth monitor by process)
    nmap # https://nmap.org
    socat # http://www.dest-unreach.org/socat
    iperf # https://github.com/esnet/iperf
    wireguard-tools # https://www.wireguard.com
    testssl # https://github.com/drwetter/testssl.sh
    sslscan # https://github.com/rbsec/sslscan
    tcping-go # https://github.com/cloverstd/tcping

    # ── File operations ────────────────────────────────────────────────────
    eza # https://github.com/eza-community/eza (modern ls)
    rsync # https://rsync.samba.org
    fd # https://github.com/sharkdp/fd
    ripgrep # https://github.com/BurntSushi/ripgrep (file/content search)
    vivid # https://github.com/sharkdp/vivid (LS_COLORS — colors.zsh)
    dust # https://github.com/bootandy/dust (du in rust)
    hexyl # https://github.com/sharkdp/hexyl (hex viewer)
    difftastic # https://github.com/Wilfred/difftastic
    moreutils # https://joeyh.name/code/moreutils (ts, sponge, etc.)
    lesspipe # https://github.com/wofr06/lesspipe (LESSOPEN handler)
    entr # https://github.com/eradman/entr (run commands on file change)
    ncdu # https://dev.yorhel.nl/ncdu (disk usage TUI)

    # ── System monitoring ──────────────────────────────────────────────────
    duf # https://github.com/muesli/duf (modern df)
    procs # https://github.com/dalance/procs (modern ps)
    glances # https://github.com/nicolargo/glances (system monitor)

    # ── Shell & terminal ───────────────────────────────────────────────────
    tmux # https://github.com/tmux/tmux
    progress # https://github.com/Xfennec/progress (coreutils progress watcher)
    pv # https://www.ivarch.com/programs/pv.shtml (progress bar for pipes)

    # ── Data & text ────────────────────────────────────────────────────────
    jq # https://jqlang.github.io/jq
    yq-go # https://github.com/mikefarah/yq (jq for YAML, JSON, XML, CSV, TOML)
    fx # https://github.com/antonmedv/fx (terminal JSON viewer)
    miller # https://github.com/johnkerl/miller (awk/sed/cut/join/sort for CSV, TSV, JSON)
    gron # https://github.com/tomnomnom/gron (greppable JSON)
    sd # https://github.com/chmln/sd (modern sed)
    choose # https://github.com/theryangeary/choose (modern cut + awk)
    gnugrep # https://www.gnu.org/software/grep (for zsh alias)
    jo # https://github.com/jpmens/jo (generate JSON from shell commands)

    # ── Developer tools ────────────────────────────────────────────────────
    nh # https://github.com/nix-community/nh (Nix helper)

    # ── Documentation & misc ──────────────────────────────────────────────
    tlrc # https://github.com/tldr-pages/tlrc (tldr client)
    fastfetch # https://github.com/fastfetch-cli/fastfetch (system info)
  ];
}
