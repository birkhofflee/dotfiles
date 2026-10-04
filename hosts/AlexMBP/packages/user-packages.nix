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

      astro-language-server # https://github.com/withastro/language-tools (astro)
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

      git-absorb # https://github.com/tummychow/git-absorb (`git absorb` — auto-fixup staged changes)
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
      awscli2
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
      croc # https://github.com/schollz/croc (p2p file transfer)
      # curlie  # redundant: xh covers this
      # curl    # redundant: use system curl or xh
      # httpie  # redundant: xh covers this
      # magic-wormhole  # redundant: croc covers p2p file transfer
      # putty

      # TLS & credentials
      mkcert # https://github.com/FiloSottile/mkcert
      _1password-cli # https://1password.com/downloads/command-line
      age # https://github.com/FiloSottile/age
      # yubikey-manager
      # yubikey-personalization
      # yubico-piv-tool

      # Network analysis & tools
      doggo # https://github.com/mr-karan/doggo (modern dig)
      hey # https://github.com/rakyll/hey (HTTP load generator)
      ipcalc # https://gitlab.com/ipcalc/ipcalc (IPv4/IPv6 address calculator)
      mitmproxy # https://mitmproxy.org
      nali # https://github.com/zu1k/nali (IP geolocation lookup)
      nexttrace # https://github.com/nxtrace/NTrace-core (visual traceroute)
      rtmpdump # https://rtmpdump.mplayerhq.hu
      stress # https://people.seas.harvard.edu/~apw/stress
      tcpflow # https://github.com/simsong/tcpflow
      ookla-speedtest # https://www.speedtest.net/apps/cli
      tcpreplay # https://tcpreplay.appneta.com
      tcptraceroute # https://github.com/mct/tcptraceroute
      wakeonlan # https://github.com/jpoliv/wakeonlan
      dns2tcp # https://www.hsc.fr/ressources/outils/dns2tcp
      dnslookup # https://github.com/ameshkov/dnslookup
      # tldx

      # VPN & security testing
      wireguard-go # https://github.com/WireGuard/wireguard-go
      sqlmap # https://github.com/sqlmapproject/sqlmap
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

      viddy # https://github.com/sachaos/viddy (modern watch)
      glow # https://github.com/charmbracelet/glow (markdown in terminal)
      viu # https://github.com/atanunq/viu (images in terminal)
      termdown # https://github.com/trehn/termdown (countdown timer)
      pop # https://github.com/charmbracelet/pop (email from terminal)
      getopt # https://frodo.looijaard.name/project/getopt
      # gotop  # redundant: htop/bottom cover this
      # procs  # redundant: htop/bottom cover this
      # emojify # https://github.com/mrowa44/emojify

      # ============================================================================
      # FILE UTILITIES
      # ============================================================================

      coreutils-prefixed # https://www.gnu.org/software/coreutils
      qpdf # https://github.com/qpdf/qpdf
      html-tidy # https://github.com/htacg/tidy-html5
      gnused # https://www.gnu.org/software/sed

      # Archive utilities
      gnutar # https://www.gnu.org/software/tar
      xz # https://tukaani.org/xz
      p7zip

      # Diff
      vbindiff # https://www.cjmweb.net/vbindiff (visual binary diff in hex & ASCII)

      # Search
      pdfgrep # https://pdfgrep.org

      # ============================================================================
      # DATA & TEXT PROCESSING
      # ============================================================================

      # JSON / YAML / structured data
      jc # https://github.com/kellyjonbrazil/jc (convert CLI tool output to JSON)
      htmlq # https://github.com/mgdm/htmlq (jq for HTML)

      # CSV / tabular data
      xan # https://github.com/medialab/xan (CSV processing)
      qsv # https://github.com/dathere/qsv (CSV manipulation)
      visidata # https://www.visidata.org (interactive tabular data TUI)

      # Text manipulation
      up # https://github.com/akavel/up (interactive pipe builder)
      serpl # https://github.com/yassinebridi/serpl (global search & replace TUI)

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

      # Notifications
      noti # https://github.com/variadico/noti

      # Misc
      # cowsay
      # lolcat

      # ============================================================================
      # NIX & PLATFORM TOOLS
      # ============================================================================

      # @see https://github.com/cli/cli/blob/trunk/docs/gh-vs-hub.md#should-i-use-gh-or-hub
      gh # https://cli.github.com

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
    ++ (pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [

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
    ++ (pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [

      plocate # https://plocate.sesse.net (very fast locate)

    ]);
}
