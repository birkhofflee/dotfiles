{ pkgs, ... }:

let
  ocr = pkgs.callPackage ../../../packages/ocr/ocr.nix { };
  impbcopy = pkgs.callPackage ../../../packages/impbcopy/impbcopy.nix { };
in
{
  home.packages =
    with pkgs;
    [
      # ============================================================================
      # DEVELOPMENT
      # ============================================================================

      # Go
      go # https://go.dev
      golangci-lint # https://github.com/golangci/golangci-lint

      # Rust
      # Not using overlay
      # `rustup component add rust-analyzer` is required for LSP to work
      # @see https://discourse.nixos.org/t/why-should-i-use-overlay-for-rust-devshell/57082/2
      rustup # https://rustup.rs
      cargo-edit # https://github.com/killercup/cargo-edit

      # Build tools
      autoconf # https://www.gnu.org/software/autoconf
      automake # https://www.gnu.org/software/automake
      # gcc
      just # https://github.com/casey/just
      pkg-config # https://www.freedesktop.org/wiki/Software/pkg-config
      wasm-pack # https://github.com/rustwasm/wasm-pack
      icu77 # https://icu.unicode.org

      # Code quality
      yamllint # https://github.com/adrienverge/yamllint

      # ============================================================================
      # LANGUAGE SERVERS
      # ============================================================================

      bash-language-server # https://github.com/bash-lsp/bash-language-server
      cmake-language-server # https://github.com/regen100/cmake-language-server
      vscode-css-languageserver # https://github.com/microsoft/vscode (css, scss)
      beam28Packages.elixir-ls # https://github.com/elixir-lsp/elixir-ls
      gopls # https://pkg.go.dev/golang.org/x/tools/gopls (go)
      graphql-language-service-cli # https://github.com/graphql/graphiql
      docker-language-server # https://github.com/microsoft/compose-language-service (dockerfile, compose)
      terraform-ls # https://github.com/hashicorp/terraform-ls (hcl)
      superhtml # https://github.com/kristoff-it/superhtml (html)
      jdt-language-server # https://projects.eclipse.org/projects/eclipse.jdt.ls (java)
      typescript-language-server # https://github.com/typescript-language-server/typescript-language-server (js, ts, tsx)
      jq-lsp # https://github.com/wader/jq-lsp
      vscode-json-languageserver # https://github.com/microsoft/vscode (json)
      kotlin-language-server # https://github.com/fwcd/kotlin-language-server
      texlab # https://github.com/latex-lsp/texlab (latex)
      typst # https://github.com/typst/typst
      lua-language-server # https://github.com/LuaLS/lua-language-server
      marksman # https://github.com/artempyanykh/marksman (markdown)
      nil # https://github.com/oxalica/nil (nix)
      perlnavigator # https://github.com/bscan/PerlNavigator
      intelephense # https://intelephense.com (php)
      ruff # https://github.com/astral-sh/ruff (python linter/formatter)
      R # https://www.r-project.org
      ruby-lsp # https://github.com/Shopify/ruby-lsp
      lldb # https://lldb.llvm.org (rust debugging, provides lldb-dap for Helix DAP)
      solc # https://github.com/ethereum/solidity
      svelte-language-server # https://github.com/sveltejs/language-tools
      systemd-lsp # https://github.com/psacawa/systemd-language-server
      taplo # https://github.com/tamasfe/taplo (toml)
      vue-language-server # https://github.com/vuejs/language-tools
      yaml-language-server # https://github.com/redhat-developer/yaml-language-server
      zls # https://github.com/zigtools/zls (zig)

      # ============================================================================
      # VERSION CONTROL
      # ============================================================================

      git-open # https://github.com/paulirish/git-open (`git open` — open GitHub page for repo)
      git-recent # https://github.com/paulirish/git-recent (`git recent` — browse local branches)
      bfg-repo-cleaner # https://rtyley.github.io/bfg-repo-cleaner

      # ============================================================================
      # INFRASTRUCTURE & DEVOPS
      # ============================================================================

      # Backup
      restic # https://restic.net

      # SSH
      ssh-copy-id # https://www.openssh.com

      # Cloud providers
      # awscli2
      # azure-cli
      # oci-cli
      # aws-vault
      # backblaze-b2
      # flarectl

      # Container & orchestration
      # k9s
      # kubectx
      # kustomize
      # kubernetes-cli
      # nomad
      # packer
      # skaffold
      # ctop

      # Infrastructure as code
      # terraform
      # terraformer
      # vagrant
      # dnscontrol

      # Log analysis
      # lnav # https://github.com/tstack/lnav

      # ============================================================================
      # NETWORKING & SECURITY
      # ============================================================================

      # HTTP clients & file transfer
      xh # https://github.com/ducaale/xh (modern curl/httpie)
      croc # https://github.com/schollz/croc (p2p file transfer)
      # curlie  # redundant: xh covers this
      # curl    # redundant: use system curl or xh
      # httpie  # redundant: xh covers this
      # magic-wormhole  # redundant: croc covers p2p file transfer
      # putty

      # Remote access
      mosh # https://mosh.org
      autossh # https://www.harding.motd.ca/autossh

      # TLS & credentials
      mkcert # https://github.com/FiloSottile/mkcert
      _1password-cli # https://1password.com/downloads/command-line
      age # https://github.com/FiloSottile/age
      # yubikey-manager
      # yubikey-personalization
      # yubico-piv-tool

      # Network analysis & tools
      knot-dns # https://www.knot-dns.cz
      bandwhich # https://github.com/imsnif/bandwhich
      doggo # https://github.com/mr-karan/doggo (modern dig)
      hey # https://github.com/rakyll/hey (HTTP load generator)
      iperf # https://github.com/esnet/iperf
      ipcalc # https://gitlab.com/ipcalc/ipcalc (IPv4/IPv6 address calculator)
      mitmproxy # https://mitmproxy.org
      nali # https://github.com/zu1k/nali (IP geolocation lookup)
      nexttrace # https://github.com/nxtrace/NTrace-core (visual traceroute)
      nmap # https://nmap.org
      rtmpdump # https://rtmpdump.mplayerhq.hu
      socat # http://www.dest-unreach.org/socat
      sslscan # https://github.com/rbsec/sslscan
      stress # https://people.seas.harvard.edu/~apw/stress
      tcpflow # https://github.com/simsong/tcpflow
      ookla-speedtest # https://www.speedtest.net/apps/cli
      tcping-go # https://github.com/cloverstd/tcping
      tcpreplay # https://tcpreplay.appneta.com
      tcptraceroute # https://github.com/mct/tcptraceroute
      wakeonlan # https://github.com/jpoliv/wakeonlan
      dns2tcp # https://www.hsc.fr/ressources/outils/dns2tcp
      dnslookup # https://github.com/ameshkov/dnslookup
      # tldx

      # VPN & security testing
      wireguard-go # https://github.com/WireGuard/wireguard-go
      wireguard-tools # https://www.wireguard.com
      sqlmap # https://github.com/sqlmapproject/sqlmap
      testssl # https://github.com/drwetter/testssl.sh
      # thc-hydra

      # ============================================================================
      # AI & MACHINE LEARNING
      # ============================================================================

      mods # https://github.com/charmbracelet/mods
      # crush
      # ollama
      # aichat
      # gfortran
      # openblas.dev

      # ============================================================================
      # TERMINAL & SHELL
      # ============================================================================

      tmux # https://github.com/tmux/tmux
      viddy # https://github.com/sachaos/viddy (modern watch)
      lesspipe # https://github.com/wofr06/lesspipe
      glow # https://github.com/charmbracelet/glow (markdown in terminal)
      termdown # https://github.com/trehn/termdown (countdown timer)
      pop # https://github.com/charmbracelet/pop (email from terminal)
      moreutils # https://joeyh.name/code/moreutils
      getopt # https://frodo.looijaard.name/project/getopt
      progress # https://github.com/Xfennec/progress (coreutils progress watcher)
      pv # https://www.ivarch.com/programs/pv.shtml (progress bar for pipes)
      # gotop  # redundant: htop/bottom cover this
      # procs  # redundant: htop/bottom cover this
      # emojify # https://github.com/mrowa44/emojify

      # ============================================================================
      # FILE UTILITIES
      # ============================================================================

      entr # https://github.com/eradman/entr (run commands on file change)
      hexyl # https://github.com/sharkdp/hexyl (hex viewer)
      coreutils-prefixed # https://www.gnu.org/software/coreutils
      eza # https://github.com/eza-community/eza (modern ls)
      rsync # https://rsync.samba.org
      dust # https://github.com/bootandy/dust (du in rust)
      qpdf # https://github.com/qpdf/qpdf
      html-tidy # https://github.com/htacg/tidy-html5
      gnutar # https://www.gnu.org/software/tar
      gnused # https://www.gnu.org/software/sed
      xz # https://tukaani.org/xz

      # Diff
      difftastic # https://github.com/Wilfred/difftastic
      vbindiff # https://www.cjmweb.net/vbindiff (visual binary diff in hex & ASCII)

      # Search
      fd # https://github.com/sharkdp/fd
      ripgrep # https://github.com/BurntSushi/ripgrep
      pdfgrep # https://pdfgrep.org

      vivid # https://github.com/sharkdp/vivid (LS_COLORS generator)

      # ============================================================================
      # DATA & TEXT PROCESSING
      # ============================================================================

      # JSON / YAML / structured data
      jq # https://jqlang.github.io/jq
      yq-go # https://github.com/mikefarah/yq (jq for YAML, JSON, XML, CSV, TOML)
      fx # https://github.com/antonmedv/fx (terminal JSON viewer)
      jc # https://github.com/kellyjonbrazil/jc (convert CLI tool output to JSON)
      jo # https://github.com/jpmens/jo (generate JSON from shell commands)
      htmlq # https://github.com/mgdm/htmlq (jq for HTML)
      gron # https://github.com/tomnomnom/gron (greppable JSON)

      # CSV / tabular data
      xan # https://github.com/medialab/xan (CSV processing)
      qsv # https://github.com/dathere/qsv (CSV manipulation)
      visidata # https://www.visidata.org (interactive tabular data TUI)
      miller # https://github.com/johnkerl/miller (awk/sed/cut/join/sort for CSV, TSV, JSON)

      # Text manipulation
      up # https://github.com/akavel/up (interactive pipe builder)
      choose # https://github.com/theryangeary/choose (modern cut + awk)
      gnugrep # https://www.gnu.org/software/grep
      sd # https://github.com/chmln/sd (modern sed)
      serpl # https://github.com/yassinebridi/serpl (global search & replace TUI)

      # ============================================================================
      # SYSTEM MONITORING
      # ============================================================================

      duf # https://github.com/muesli/duf (modern df)
      glances # https://github.com/nicolargo/glances

      # ============================================================================
      # MEDIA & DOWNLOAD
      # ============================================================================

      # Media processing
      ffmpeg # https://ffmpeg.org
      exiftool # https://exiftool.org
      imagemagickBig # https://imagemagick.org
      optipng # https://optipng.sourceforge.net
      oxipng # https://github.com/oxipng/oxipng (multithreaded PNG optimizer in rust)

      # Download & streaming
      lux # https://github.com/iawia002/lux (video downloader)
      yt-dlp # https://github.com/yt-dlp/yt-dlp
      sox # https://sourceforge.net/projects/sox (used by Claude Code to record audio)

      # ============================================================================
      # PRODUCTIVITY
      # ============================================================================

      # Recording & presentation
      asciinema # https://asciinema.org
      # slides

      # Documentation & help
      cht-sh # https://github.com/chubin/cheat.sh
      tldr # https://github.com/tldr-pages/tldr

      # Notifications
      noti # https://github.com/variadico/noti

      # Misc
      fastfetch # https://github.com/fastfetch-cli/fastfetch
      # cowsay
      # lolcat

      # ============================================================================
      # NIX & PLATFORM TOOLS
      # ============================================================================

      # @see https://github.com/cli/cli/blob/trunk/docs/gh-vs-hub.md#should-i-use-gh-or-hub
      gh # https://cli.github.com

      nh # https://github.com/nix-community/nh
      cachix # https://cachix.org

      # powershell
      # stripe-cli
      # dex2jar
      # hyperfine # https://github.com/sharkdp/hyperfine (cli benchmarking)

      # ============================================================================
      # FONTS
      # ============================================================================

      # lcdf-typetools
      berkeley-mono # https://berkeleygraphics.com/typefaces/berkeley-mono
      berkeley-mono-variable # https://berkeleygraphics.com/typefaces/berkeley-mono
      commit-mono-nf # https://commitmono.com
      noto-fonts-cjk-sans-static # https://github.com/notofonts/noto-cjk
      monaspace # https://monaspace.githubnext.com
      sarasa-gothic # https://github.com/be5invis/Sarasa-Gothic
    ]
    # macOS-only packages
    ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [

      m-cli # https://github.com/rgcr/m-cli
      blueutil # https://github.com/toy/blueutil
      mas # https://github.com/mas-cli/mas
      stats # https://github.com/exelban/stats
      mactop # https://github.com/context-labs/mactop
      osx-cpu-temp # https://github.com/lavoiesl/osx-cpu-temp

      pinentry_mac # https://github.com/GPGTools/pinentry
      pam-reattach # https://github.com/fabianishere/pam_reattach
      reattach-to-user-namespace # https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard

      ocr # packages/ocr/ocr.nix
      impbcopy # packages/impbcopy/impbcopy.nix
      supercharge # packages/supercharge.nix https://sindresorhus.com/supercharge
      pngpaste # https://github.com/jcsalterego/pngpaste
      create-dmg # https://github.com/create-dmg/create-dmg
      terminal-notifier # https://github.com/julienXX/terminal-notifier
    ])
    # Linux-only packages
    ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [

      plocate # https://plocate.sesse.net (very fast locate)

    ]);
}
