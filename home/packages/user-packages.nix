{ pkgs, ... }:

{
  home.packages =
    with pkgs;
    [
      # ============================================================================
      # DEVELOPMENT TOOLS AND LIBRARIES
      # ============================================================================

      # Go
      go
      golangci-lint

      # Node.js
      nodejs_22
      yarn

      # Ruby
      rbenv

      # Build tools/libraries
      autoconf
      automake
      # gcc
      just
      pkg-config
      wasm-pack
      icu77

      # Package managers
      uv

      # Language Servers (and/or its toolchains)
      bash-language-server
      cmake-language-server
      vscode-css-languageserver # css, scss
      beam28Packages.elixir-ls
      gopls # go
      graphql-language-service-cli # graphql
      docker-language-server # dockerfile, compose files, bake
      terraform-ls # hcl
      superhtml # html
      jdt-language-server # java
      typescript-language-server # js, ts, tsx
      jq-lsp # jq
      vscode-json-languageserver # json
      kotlin-language-server
      texlab # latex
      lua-language-server # lua
      marksman # markdown
      nil # nix
      perlnavigator # perl
      intelephense # php
      ruff # python
      R
      ruby-lsp # Ruby
      # rust-bin.stable.latest.default # rust
      solc # solidity
      svelte-language-server # svelte
      systemd-lsp # systemd
      taplo # TOML
      vue-language-server
      yaml-language-server
      zls # zig

      # ============================================================================
      # VERSION CONTROL
      # ============================================================================

      # Git
      git
      git-lfs
      git-extras # https://github.com/tj/git-extras/blob/main/Commands.md
      git-open # `git open` to open the GitHub page or website for a repo
      git-recent # `git recent` to browse latest local git branches interactively
      lazygit

      # Git tools
      bfg-repo-cleaner

      # ============================================================================
      # INFRASTRUCTURE & DEVOPS
      # ============================================================================

      # Utilities
      # lnav # log file navigator (https://github.com/tstack/lnav)

      # Cloud providers
      # awscli2
      # azure-cli
      # oci-cli
      # aws-vault
      backblaze-b2
      # flarectl

      # Container & orchestration
      # k9s
      # kubectx
      # kustomize
      # kubernetes-cli
      # nomad
      # packer
      # skaffold
      # ctop # top for containers

      # Infrastructure as code
      # terraform
      # terraformer
      # vagrant

      # DNS & networking
      # dnscontrol

      # Backup & storage
      restic

      # SSH
      ssh-copy-id

      # ============================================================================
      # NETWORKING & SECURITY
      # ============================================================================

      curlie
      curl
      xh
      mosh
      autossh
      magic-wormhole # p2p file transfer
      croc # p2p file transfer
      # putty # FIXME: https://github.com/NixOS/nixpkgs/pull/449689

      # TLS
      mkcert

      # Encryption
      age
      # yubikey-manager
      # yubikey-personalization

      # Network analysis
      knot-dns
      # tldx # domain availability search
      bandwhich
      doggo # modern dig
      hey
      iperf
      ipcalc # network address calculations for IPv4 and IPv6 (https://gitlab.com/ipcalc/ipcalc)
      mitmproxy
      nali
      nexttrace
      nmap
      rtmpdump
      socat
      sslscan
      stress
      tcpflow
      ookla-speedtest
      tcping-go
      tcpreplay
      tcptraceroute
      trippy
      wakeonlan
      dns2tcp
      tcptrace
      dnslookup

      # VPN & security
      wireguard-go
      wireguard-tools
      sqlmap
      thc-hydra # network logon cracker
      testssl

      # ============================================================================
      # AUTHENTICATION & SECURITY
      # ============================================================================

      gnupg
      # yubico-piv-tool

      # ============================================================================
      # AI & MACHINE LEARNING
      # ============================================================================

      # gfortran
      # openblas.dev
      # gemini-cli
      # crush
      # ollama
      # aichat
      mods

      # ============================================================================
      # DEVELOPMENT UTILITIES
      # ============================================================================

      # Web development
      # caddy
      httpie

      # Code quality
      dprint
      yamllint

      # Databases
      # redis
      # pgcli

      # ============================================================================
      # SYSTEM UTILITIES
      # ============================================================================

      # Shell enhancements
      zsh-completions
      zsh-fast-syntax-highlighting
      emojify
      atuin
      progress
      pv # progress bar for a pipe
      television
      yazi

      # Terminal utilities
      tmux
      htop
      gotop
      procs
      viddy
      lesspipe
      glow # markdown in the terminal (https://github.com/charmbracelet/glow)
      termdown # timer https://github.com/trehn/termdown
      pop # email sender https://github.com/charmbracelet/pop

      # General shell utilities
      moreutils # https://joeyh.name/code/moreutils/
      getopt

      # File operations
      entr # run arbitrary commands when files change
      bat
      hexyl # modern hex viewer
      coreutils-prefixed
      eza
      rsync
      tree
      dust # du in rust (https://github.com/bootandy/dust)
      qpdf
      html-tidy
      gnutar
      gnused

      # Diff
      difftastic
      delta
      vbindiff # Visual Binary Diff compares files in hex & ASCII formats

      vivid # LS_COLORS generator (https://github.com/sharkdp/vivid)
      zoxide

      # Searcher
      fd
      fzf
      ripgrep
      silver-searcher
      pdfgrep

      # Data Science
      xan # csv file processing (https://github.com/medialab/xan)
      qsv # csv manipulation (https://github.com/dathere/qsv)
      visidata # Interactive terminal multitool for tabular data
      miller # awk, sed, cut, join, and sort for CSV, TSV, JSON
      gron # greppable JSON (https://github.com/tomnomnom/gron)

      # Text operations
      jq
      up # https://github.com/akavel/up
      fx # terminal JSON viewer
      choose # modern cut+awk (https://github.com/theryangeary/choose)
      gnugrep
      sd
      serpl # global search & replace TUI
      jc # convert output of common cli tools to JSON (https://github.com/kellyjonbrazil/jc?tab=readme-ov-file#parsers)
      jo # generate JSON by simple commands
      yq-go # jq for YAML, JSON, XML, CSV, TOML and properties
      htmlq # jq for HTML (https://github.com/mgdm/htmlq)

      # System monitoring
      duf
      jc
      bottom # btm (https://github.com/ClementTsang/bottom)
      glances

      # ============================================================================
      # UTILITIES & TOOLS
      # ============================================================================

      # Recording & presentation
      asciinema
      slides

      # Documentation & help
      cht-sh
      tldr

      # Fun & misc
      cowsay
      lolcat
      neofetch

      # Notifications
      noti

      # Download & media
      lux
      yt-dlp

      # ============================================================================
      # MEDIA PROCESSING
      # ============================================================================

      ffmpeg
      exiftool
      imagemagickBig
      optipng

      # ============================================================================
      # CLI TOOLS
      # ============================================================================

      # powershell
      # stripe-cli
      # dex2jar
      # hyperfine # cli command benchmarking

      # GitHub CLI Tools
      # @see https://github.com/cli/cli/blob/trunk/docs/gh-vs-hub.md#should-i-use-gh-or-hub
      gh
      hub

      # Nix Tools
      nh # https://github.com/nix-community/nh
      cachix

      # ============================================================================
      # FONTS
      # ============================================================================
      lcdf-typetools
      berkeley-mono
      commit-mono-nf
      noto-fonts-cjk-sans-static
      monaspace
    ]
    # macOS-only packages
    ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [

      m-cli
      blueutil
      mas
      stats
      mactop
      osx-cpu-temp

      ryubing

      pinentry_mac
      pam-reattach
      reattach-to-user-namespace

      ocr
      pngpaste
      create-dmg
      terminal-notifier
    ])
    # Linux-only packages
    ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [

      plocate # very fast `locate`

    ]);
}
