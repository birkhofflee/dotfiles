{
  description = "birkhoff's dotfiles";

  nixConfig = {
    # Merged with the system-level substituters to speed up the initial build.
    # Has to be a literal, so keep it in sync with lib/caches.nix by hand.
    # Requires the invoking user to be in trusted-users (see installation instructions).
    #
    # Once the user is in trusted-users, --accept-flake-config will pick up the
    # substituters from the flake's nixConfig without any manual pre-seeding.
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://helix.cachix.org"
      "https://birkhoff.cachix.org"
      "https://claude-code.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "birkhoff.cachix.org-1:m7WmdU7PKc6fsKedC278lhLtiqjz6ZUJ6v2nkVGyJjQ="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Some other packages
    agenix.url = "github:ryantm/agenix";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Declarative pre-commit hooks (nixfmt, deadnix, statix); see `checks` below
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs-unstable";
    git-hooks.inputs.flake-compat.follows = ""; # only for non-flake users

    # _1password-shell-plugins.url = "github:1Password/shell-plugins";
    helix.url = "github:helix-editor/helix/master";

    secrets = {
      url = "git+ssh://git@github.com/birkhofflee/dotfiles.secret.git?ref=main&shallow=1";
      flake = false;
    };

    claude-code-nix.url = "github:sadjow/claude-code-nix";
    claude-code-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Prebuilt Rex (https://www.superlogical.com/rex/docs/linux/installation).
    # There's no stable channel yet; snapshot is what the Mac app tracks.
    rex.url = "https://pkgs.superlogical.com/rex/nix/snapshot.tar.gz";
    rex.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Declarative Agent Skills (see home/modules/agent-skills.nix)
    agent-skills.url = "github:Kyure-A/agent-skills-nix";
    agent-skills.inputs.nixpkgs.follows = "nixpkgs-unstable";
    emil-skills = {
      url = "github:emilkowalski/skills";
      flake = false;
    };
    cloudflare-skills = {
      url = "github:cloudflare/skills";
      flake = false;
    };
    hallmark-skills = {
      url = "github:nutlope/hallmark";
      flake = false;
    };
    improve-skills = {
      url = "github:shadcn/improve";
      flake = false;
    };
    seedex-skills = {
      url = "github:wishworldbetter/seedex-skills";
      flake = false;
    };
    vocabulary-skills = {
      url = "github:index-how/vocabulary";
      flake = false;
    };
    find-skills = {
      url = "github:vercel-labs/skills";
      flake = false;
    };
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    firecrawl-skills = {
      url = "github:firecrawl/firecrawl-workflows";
      flake = false;
    };
    paper-search-mcp = {
      url = "github:openags/paper-search-mcp";
      flake = false;
    };
    tw-formal-writing-skills = {
      url = "github:Imbad0202/tw-formal-writing";
      flake = false;
    };
    security-audit-skill = {
      url = "github:cloudflare/security-audit-skill";
      flake = false;
    };
    # A Claude Code plugin rather than plain skills (see home/modules/agent-skills.nix)
    academic-research-skills = {
      url = "github:Imbad0202/academic-research-skills";
      flake = false;
    };
  };

  outputs =
    {
      self,
      ...
    }@inputs:
    let
      inherit (inputs.nixpkgs-unstable.lib) attrValues genAttrs mapAttrs;

      overlaysList = attrValues self.overlays;

      # Helper function to create system configurations
      mkSystem = import ./lib/mksystem.nix {
        nixpkgs = inputs.nixpkgs-unstable;
        overlays = overlaysList;
        inherit inputs;
      };

      # Per-system pkgs, evaluated once per system and shared by every
      # per-system output below.
      perSystem = genAttrs [ "aarch64-darwin" "x86_64-linux" ] (
        system:
        let
          pkgs = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
            overlays = overlaysList;
          };
        in
        {
          inherit system pkgs;
          # Tree-wide validation and linting. Runs as a git pre-commit hook
          # (installed by the devShell, i.e. on `direnv`/`nix develop`) and as
          # `checks.<system>.pre-commit-check` in `nix flake check`.
          preCommitCheck = inputs.git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              # Standard formatting (RFC 166)
              nixfmt.enable = true;

              # Linting: unused code and anti-patterns. statix reads
              # statix.toml at the repo root.
              deadnix.enable = true;
              statix.enable = true;
            };
          };
        }
      );
      eachSystem = f: mapAttrs (_: f) perSystem;
    in
    {
      overlays = {
        claude-code = inputs.claude-code-nix.overlays.default;

        custom-packages = _: prev: {
          age-with-plugins = prev.callPackage ./packages/age-with-plugins.nix { };
          berkeley-mono = prev.callPackage ./packages/fonts/berkeley-mono.nix { inherit (inputs) secrets; };
          berkeley-mono-variable = prev.callPackage ./packages/fonts/berkeley-mono-variable.nix {
            inherit (inputs) secrets;
          };
          commit-mono-nf = prev.callPackage ./packages/fonts/commit-mono-nf.nix { };
          supercharge = prev.callPackage "${inputs.secrets}/packages/supercharge.nix" { };
        };

        python-llm-plugins = _: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (
              python-final: _:
              prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
                llm-mlx = python-final.callPackage ./packages/llm-mlx.nix { };
              }
            )
          ];
        };
      };

      darwinConfigurations = {
        AlexMBP = mkSystem "AlexMBP" {
          system = "aarch64-darwin";
          user = "ale";
          hasDesktop = true;
        };
      };

      nixosConfigurations = {
        # nixos-server-01 is configured from ~/Documents/Infrastructure/Homelab,
        # not here. This repo still *uses* that host — nixos-desktop-01 forwards
        # every build to it (hosts/nixos-desktop-01/remote-builder.nix) and
        # `just cache-determinate` builds and pushes there — but it no longer
        # defines it.
        nixos-desktop-01 = mkSystem "nixos-desktop-01" {
          system = "x86_64-linux";
          user = "ale";
          hasDesktop = true;
        };
      };

      # Standalone home-manager for non-NixOS Linux boxes (e.g. WSL), where
      # mkSystem can't be used. Apply with:
      #   home-manager switch --flake .#ale@wsl
      homeConfigurations."ale@wsl" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit (perSystem.x86_64-linux) pkgs;
        extraSpecialArgs = {
          inherit inputs;
          currentSystemUser = "ale";
          hasDesktop = false;
        };
        modules = [
          ./home
          # mkSystem normally adds these at the system level
          inputs.nix-index-database.homeModules.nix-index
          inputs.rex.homeManagerModules.default
          {
            # Personal Rex server as a systemd user service (linger is on, so
            # it starts at boot), reachable over its own embedded tailnet node.
            # Also writes xterm-rex to ~/.terminfo, which the Nix-built zsh
            # needs: its ncurses doesn't search /usr/share/terminfo.
            services.rex = {
              enable = true;
              # Keep the name the node was enrolled under; changing it
              # creates a new node that has to sign in again.
              tailscale.enable = true;
              tailscale.hostname = "wsl-rex";
            };
            # programs.ssh isn't managed here, and the distro's rex package
            # already installs the guard in /etc/ssh/ssh_config.d.
            programs.rex.sshGuard = false;

            programs.nix-index-database.comma.enable = true;
            targets.genericLinux.enable = true;
            # ssh.nix publishes the 1Password key's pubkey; this box has its
            # own on-disk keypair, which that would leave mismatched.
            home.file.".ssh/id_ed25519.pub".enable = false;
            # Applied from a github: ref, so there's no ~/.config/dotfiles checkout
            # for the LazyVim out-of-store symlink to point at.
            dotfiles.neovim.mutableConfig = false;
          }
        ];
      };

      packages.x86_64-linux.nixos-desktop-01-image =
        self.nixosConfigurations.nixos-desktop-01.config.system.build.VMA;

      # `remoteBuild = true` means "build on the target node": deploy-rs copies
      # the .drv over and runs `nix build --store ssh://<node>`, so the node's
      # own daemon does the work. deploy-rs has no build-host concept, and the
      # only alternative (`false`) builds on whichever machine invoked `deploy`
      # and then copies the closure over — which would drag every deploy through
      # the Mac. Instead the *nodes* decide where their builds land:
      # nixos-desktop-01 forwards them to nixos-server-01 via `nix.buildMachines`
      # (see hosts/nixos-desktop-01/remote-builder.nix), so the Mac only ever
      # evaluates and orchestrates.
      deploy.nodes.nixos-desktop-01 = {
        hostname = "nixos-desktop-01";
        profiles.system = {
          sshUser = "ale";
          user = "root";
          remoteBuild = true;
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixos-desktop-01;
        };
      };

      # Same formatter the pre-commit hook enforces, so `nix fmt` fixes whatever
      # the hook rejects.
      formatter = eachSystem ({ pkgs, ... }: pkgs.nixfmt-tree);

      checks = eachSystem (
        { preCommitCheck, ... }:
        {
          pre-commit-check = preCommitCheck;
        }
      );

      devShells = eachSystem (
        {
          system,
          pkgs,
          preCommitCheck,
        }:
        {
          default =
            let
              # Override agenix to use Determinate Nix instead of its bundled nix-2.28.4.
              # Without this, agenix warns about eval-cores/lazy-trees being unknown settings.
              nixDeterminate = pkgs.writeShellScriptBin "nix-instantiate" ''
                exec /nix/var/nix/profiles/default/bin/nix-instantiate "$@"
              '';
              agenix = inputs.agenix.packages.${system}.default.override {
                nix = nixDeterminate;
              };
            in
            pkgs.mkShellNoCC {
              packages = [
                pkgs.just
                pkgs.ssh-copy-id
                pkgs.nh
                pkgs.cachix
                pkgs.attic-client
                pkgs.nixfmt-tree
                agenix
                pkgs.deploy-rs
              ]
              ++ preCommitCheck.enabledPackages;

              # Installs .git/hooks/pre-commit and links .pre-commit-config.yaml
              inherit (preCommitCheck) shellHook;

              NH_FLAKE = ".";
            };
        }
      );
    };
}
