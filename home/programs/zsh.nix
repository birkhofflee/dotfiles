{
  config,
  pkgs,
  lib,
  ...
}:

{
  # https://github.com/jnunyez/home-manager/blob/master/modules/programs/zsh.nix
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    # Zsh startup profiling for performance analysis.
    zprof.enable = false;

    autosuggestion = {
      enable = true;
      strategy = [ ];
    };

    # Helix mode would be nice, however Multirious/zsh-helix-mode
    # still has some compatibility issues and some bugs that I cannot
    # bear. (Oct 2025)
    defaultKeymap = "emacs";

    # This lets you change to any dir without having to type `cd`, that is, by just
    # typing its name. Be warned, though: This can misfire if there exists an alias,
    # function, builtin or command with the same name.
    # In general, I would recommend you use only the following without `cd`:
    #   ..  to go one dir up
    #   ~   to go to your home dir
    #   ~-2 to go to the 2nd mostly recently visited dir
    #   /   to go to the root dir
    # @credits https://github.com/marlonrichert/zsh-launchpad
    autocd = true;

    dirHashes = {
      dl = "$HOME/Downloads";
      desk = "$HOME/Desktop";
      docs = "$HOME/Documents";
      nix = "$HOME/.config/dotfiles";
    };

    history = {
      append = true; # Append history to the history file, instead of replaceing
      ignoreAllDups = true; # Delete an old recorded event if a new event is a duplicate.
      saveNoDups = true; # Do not write a duplicate event to the history file.
      findNoDups = true; # Do not display a previously found event.
      ignoreSpace = true; # Do not save commands that begin with a space.
      expireDuplicatesFirst = true; # Expire duplicates first when trimming history.
      extended = true; # Save the time and duration of each command in the history file.

      ignorePatterns = [ "rm * " ];
    };

    # Substituted anywhere on a line
    shellGlobalAliases = {
      UUID = "$(uuidgen | tr -d \\n)";
      G = "| grep";
    };

    shellAliases =
      let
        macAliases = lib.mkIf (pkgs.stdenv.isDarwin) {
          mtr = "sudo mtr";
          htop = "sudo htop";
          pbc = "pbcopy"; # Copy to clipboard
          pbp = "pbpaste"; # Paste from clipboard
          cpwd = "pwd | pbcopy";
          yoink = "open -a Yoink";
          a = "terminal-notifier -sound default -message 'Command complete' -title 'Shell'";
          afk = "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession -suspend";
          pubkey = "cat ~/.ssh/id_ed25519.pub | pbcopy | echo '=> Public key (ed25519) copied to pasteboard.'";
          sshkey = "pubkey";
          brewery = "brew update && brew upgrade && brew cleanup";
          o = "open"; # Open with default app
        };
        generalAliases = {
          # Disable correction
          ack = "nocorrect ack";
          cd = "nocorrect cd";
          cp = "nocorrect cp -i"; # Safe ops
          gcc = "nocorrect gcc";
          grep = "nocorrect grep --color=auto"; # use color
          ln = "nocorrect ln -i"; # Safe ops
          man = "nocorrect man";
          mkdir = "nocorrect mkdir";
          mv = "nocorrect mv -i"; # Safe ops
          rm = "nocorrect rm -i"; # Safe ops

          # Disable globbing
          curl = "noglob curl";
          wget = "noglob wget";
          fc = "noglob fc";
          find = "noglob find";
          history = "noglob history";
          locate = "noglob locate";
          rake = "noglob rake";
          rsync = "noglob rsync";
          scp = "noglob scp";
          sftp = "noglob sftp";
          nix = "noglob nix";

          # List files
          sl = "ls";
          l = "ls";
          ls = "eza -1 --group-directories-first --icons --hyperlink --no-quotes";
          ll = "ls -l";
          la = "ls -la";
          tree = "ls --tree --level 3";
          lr = "ll -R";
          lx = "ll -XB";
          lc = "lt -c";
          lu = "lt -u";

          # zmv lets you batch rename (or copy or link) files by using pattern matching.
          # https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#index-zmv
          zmv = "zmv -Mv";
          zcp = "zmv -Cv";
          zln = "zmv -Lv";

          # Directory switching
          "-" = "cd -";
          "2" = "cd +2";
          "3" = "cd +3";
          "4" = "cd +4";
          po = "popd";
          pu = "pushd";

          # Shell
          sa = "alias | grep -i"; # Search shell aliases
          history-stat = "history 0 | awk '{print $2}' | sort | uniq -c | sort -n -r | head"; # Lists the ten most used commands
          type = "type -a"; # Show all definitions of a command

          # Nix
          nix-info = "nix-shell -p nix-info --run \"nix-info -m\"";

          # LLM
          mods = "with_llm mods"; # @see https://github.com/charmbracelet/mods
          chat = "_llm chat";
          files-to-prompt = "uvx files-to-prompt";
          crush = "with_llm crush";

          # Text processing
          p = "$PAGER"; # Pager
          j = "jq -C | less -R"; # jq with pager
          diffu = "diff --unified"; # diff

          # Utilities
          http-serve = "python3 -m http.server";
          urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]))'";
          urlencode = "python3 -c 'import sys, urllib.parse as ul; print (ul.quote_plus(sys.argv[1]))'";
          lg = "lazygit";
          pop = "with_resend POP_FROM='Alex <alex@birkhoff.me>' pop"; # https://github.com/charmbracelet/pop
          scratch = "$EDITOR $(mktemp)";
          rn = "date; echo && cal";
          oggi = "echo -n \"$(date '+%Y-%m-%d')\"";
          ds-destroy = "find . -name .DS_Store -delete"; # https://codeberg.org/EvanHahn/dotfiles/src/commit/843b9ee13d949d346a4a73ccee2a99351aed285b/home/bin/bin/ds-destroy
          clear_history = "> ~/.zsh_history ; exec $SHELL -l";
          help = "cht.sh";
          du = "ncdu --color dark -rr -x --exclude .git --exclude node_modules";
          gist = "gh gist create";

          # Network
          get = "curl --continue-at - --location --progress-bar --remote-name --remote-time";
          dig = "kdig";
          q = "ssh -v";
          testdown = "http https://mensura.cdn-apple.com/api/v1/gm/config | jq -r .urls.large_https_download_url | xargs wget -O /dev/null"; # Test download speed from Apple CDN

          # Docker
          d = "docker";
          dp = "docker ps -a";
          dr = "docker rm";
          di = "docker inspect";
          dvl = "docker volume ls";
          dvi = "docker volume inspect";
          dvp = "docker volume inspect --format '{{ .Mountpoint }}'";
          dc = "docker compose";
          dclf = "docker compose logs -f";
          dcu = "docker compose up -d";
          dcr = "docker compose restart";
          dcub = "docker compose up -d --build";
          dcb = "docker compose build";
          dcd = "docker compose down";
        };
      in
      lib.mkMerge [
        generalAliases
        macAliases
      ];

    sessionVariables = lib.mkMerge [
      {
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";

        # Set the default Less options.
        # Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
        # Remove -X and -F (exit if the content fits on one screen) to enable it.
        LESS = "-F -g -i -M -R -S -w -X -z-4";

        # Use lesspipe to read non-text files
        # @see https://github.com/wofr06/lesspipe?tab=readme-ov-file#4-supported-file-formats
        LESSOPEN = "| ${pkgs.lesspipe}/bin/lesspipe.sh %s";
        LESSCOLORIZER = "bat --theme=default";
        LESSQUIET = "1"; # Suppress lesspipe help messages in output

        # Editor
        EDITOR = "hx"; # Managed by `programs.helix.defaultEditor`
        VISUAL = "hx";
        PAGER = "less";

        DO_NOT_TRACK = 1;

        ## External Tools

        # LLM (https://llm.datasette.io/en/stable/setup.html#configuration)
        LLM_USER_PATH = "${config.home.homeDirectory}/.config/llm";
        LLM_MODEL = "openrouter/google/gemini-2.5-flash";

        # Zoxide (https://github.com/ajeetdsouza/zoxide/blob/main/README.md#environment-variables)
        _ZO_ECHO = 1;

        # dotnet
        DOTNET_CLI_TELEMETRY_OPTOUT = 1;

        # Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
        PYTHONIOENCODING = "utf-8";

        # Enable persistent REPL history for `node`.
        NODE_REPL_HISTORY = "${config.home.homeDirectory}/.node_history";

        # Use sloppy mode by default, matching web browsers.
        NODE_REPL_MODE = "sloppy";

        # Erlang and Elixir shell history:
        ERL_AFLAGS = "-kernel shell_history enabled";
      }
      (lib.optionalAttrs pkgs.stdenv.isDarwin {
        SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";

        # Ansible (https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#running-on-macos-as-a-control-node)
        OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES";

        # https://docs.brew.sh/Analytics
        HOMEBREW_NO_ANALYTICS = "1";
      })
    ];

    profileExtra = ''
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        eval "$(${if pkgs.stdenv.isAarch64 then "/opt/homebrew/bin" else "/usr/local/bin"}/brew shellenv)"
      ''}
    '';

    completionInit = ''
      # Regenerate the completion cache file (~/.zcompdump) if it's older than 24 hours
      autoload -Uz compinit
      for dump in ~/.zcompdump(N.mh+24); do
        compinit
      done
      compinit -C

      # Completions for git-extras doesn't load automatically
      # due to the lack of #compdef directive. We need to source it manually.
      source ${pkgs.git-extras}/share/zsh/site-functions/_git_extras
    '';

    # Content to be added to `.zshrc`.
    #
    # To specify the order, use `lib.mkOrder`. Common order values:
    # - 500 (mkBefore): Early initialization (replaces initExtraFirst)
    # - 550: Before completion initialization (replaces initExtraBeforeCompInit)
    # - 1000 (default): General configuration (replaces initExtra)
    # - 1500 (mkAfter): Last to run configuration
    #
    # Note: zprof starts with order 400 and ends with order 1450
    initContent =
      let
        # This runs instantly
        zshConfigEarlyInit = lib.mkBefore ''
          source "${config.home.homeDirectory}/.shell/keys.zsh"
          source "${config.home.homeDirectory}/.shell/options.zsh"

          # Load Zsh's rename utility `zmv`
          autoload -Uz zmv
        '';

        # This runs before compinit (completion initialization)
        zshConfigBeforeCompInit = lib.mkOrder 550 ''
          # OrbStack
          # This adds fpath so needs to be before compinit
          if test -f ~/.orbstack/shell/init.zsh; then
            source ~/.orbstack/shell/init.zsh 2>/dev/null || :
          fi

          source "${config.home.homeDirectory}/.shell/colors.zsh"
          source "${config.home.homeDirectory}/.shell/completions.zsh"
          source "${config.home.homeDirectory}/.shell/fzf.zsh"
        '';

        # General configuration
        zshConfig = ''
          source "${config.home.homeDirectory}/.shell/functions.zsh"
          source "${config.home.homeDirectory}/.shell/op.zsh"

          ${lib.optionalString pkgs.stdenv.isDarwin ''
            source "${config.home.homeDirectory}/.shell/proxy.zsh"
          ''}

          eval "$(rbenv init - zsh)"

          # zsh-auto-notify (https://github.com/MichaelAquilina/zsh-auto-notify)
          # Note: `lg` is alias for `lazygit`
          AUTO_NOTIFY_IGNORE=(
            "vim" "nvim" "hx" "nano"
            "tmux"
            "zellij"
            "bat"
            "cat"
            "less"
            "more"
            "watch"
            "top"
            "htop"
            "ssh"
            "man"
            "zi"
            "lazygit"
            "lg"
          );

          # Empty the autosuggestion strategy array. Later atuin will
          # automatically add itself into this array, so we're sure
          # that it's the only source where autosuggestions are fetched
          ZSH_AUTOSUGGEST_STRATEGY=()
        '';

        # This loads at the end of zshrc
        zshEndOfConfig = lib.mkAfter ''
          # `zsh-syntax-highlighting` must be sourced at the end of the .zshrc file
          # @see https://github.com/zsh-users/zsh-syntax-highlighting?tab=readme-ov-file#why-must-zsh-syntax-highlightingzsh-be-sourced-at-the-end-of-the-zshrc-file
          source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
        '';
      in
      lib.mkMerge [
        zshConfigEarlyInit
        zshConfigBeforeCompInit
        zshConfig
        zshEndOfConfig
      ];

    # https://nix-community.github.io/home-manager/options.html#opt-programs.zsh.plugins
    plugins = [
      {
        name = "extract";
        src = pkgs.fetchFromGitHub {
          # https://github.com/birkhofflee/zsh-plugin-extract
          owner = "birkhofflee";
          repo = "zsh-plugin-extract";
          rev = "1.0.0";
          sha256 = "sha256-KjQoMGqbrjuvfy+Lf3eI32aN09sLpHjh5S/tRTnhAco=";
        };
      }
      {
        name = "you-should-use";
        src = pkgs.fetchFromGitHub {
          # https://github.com/MichaelAquilina/zsh-you-should-use
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "64dd9e3ff977e4ae7d024602b2d9a7a4f05fd8f6";
          sha256 = "sha256-u3abhv9ewq3m4QsnsxT017xdlPm3dYq5dqHNmQhhcpI=";
        };
      }
      {
        name = "auto-notify";
        src = pkgs.fetchFromGitHub {
          # https://github.com/MichaelAquilina/zsh-auto-notify
          owner = "MichaelAquilina";
          repo = "zsh-auto-notify";
          rev = "b51c934d88868e56c1d55d0a2a36d559f21cb2ee";
          sha256 = "sha256-s3TBAsXOpmiXMAQkbaS5de0t0hNC1EzUUb0ZG+p9keE=";
        };
      }
      {
        name = "gnu-utility";
        file = "";
        src = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/sorin-ionescu/prezto/8d00c51900dfce3b2bc1e5bd99bd58f238c5668a/modules/gnu-utility/init.zsh";
          sha256 = "sha256-5sx3r71NGT9DokDVwfjlKomYzIgpRwaA2Ky01QRN9sY=";
        };
      }
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          # https://github.com/Aloxaf/fzf-tab
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "2abe1f2f1cbcb3d3c6b879d849d683de5688111f";
          sha256 = "sha256-zc9Sc1WQIbJ132hw73oiS1ExvxCRHagi6vMkCLd4ZhI=";
        };
      }
    ];
  };
}
