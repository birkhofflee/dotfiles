{
  description = "birkhoff's dotfiles";

  nixConfig = {
    # Merged with the system-level substituters.
    # This config is included to speed up the initial build.
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://helix.cachix.org"
      "https://birkhoff.cachix.org"
      "https://mitchellh-nixos-config.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "birkhoff.cachix.org-1:m7WmdU7PKc6fsKedC278lhLtiqjz6ZUJ6v2nkVGyJjQ="
      "mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ="
    ];
  };

  inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # For provisioning NixOS machines with nixos-anywhere
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-stable";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Some other packages
    agenix.url = "github:ryantm/agenix";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-unstable";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    # _1password-shell-plugins.url = "github:1Password/shell-plugins";
    helix.url = "github:helix-editor/helix/master";

    # Zellij stuff
    zjstatus.url = "github:dj95/zjstatus";
    zjstatus-hints.url = "github:b0o/zjstatus-hints";
    zj-quit.url = "github:dj95/zj-quit";

    secrets = {
      url = "git+ssh://git@github.com/BirkhoffLee/dotfiles.secret.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      ...
    }@inputs:
    # https://github.com/malob/nixpkgs/blob/61d4809925a523296278885ff8a75d3776a5c813/flake.nix#L34
    let
      inherit (inputs.nixpkgs-unstable.lib) attrValues optionalAttrs singleton;

      # Overlays configuration
      overlaysList =
        attrValues self.overlays
        ++ singleton (
          final: prev:
          (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            # Sub in x86 version of packages that don't build on Apple Silicon.
            inherit (final.pkgs-x86)
              agda
              idris2
              ;
          })
          // {
            # Add other overlays here if needed.
          }
        );

      nixpkgsDefaults = {
        config = {
          allowUnfree = true;
        };
        overlays = overlaysList;
      };

      # Helper function to create system configurations
      mkSystem = import ./lib/mksystem.nix {
        nixpkgs = inputs.nixpkgs-unstable;
        overlays = overlaysList;
        inherit inputs;
      };
    in
    {
      overlays = {
        # Overlays to add different versions `nixpkgs` into package set
        pkgs-master = _: prev: {
          pkgs-master = import inputs.nixpkgs-master {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };
        pkgs-stable = _: prev: {
          pkgs-stable = import inputs.nixpkgs-stable {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };
        pkgs-unstable = _: prev: {
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };
        apple-silicon =
          _: prev:
          optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs-unstable {
              system = "x86_64-darwin";
              inherit (nixpkgsDefaults) config;
            };
          };

        rust = inputs.rust-overlay.overlays.default;

        zellij-plugins = _: prev: {
          zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;
          zjstatus-hints = inputs.zjstatus-hints.packages.${prev.stdenv.hostPlatform.system}.default;
          zj-quit = inputs.zj-quit.packages.${prev.stdenv.hostPlatform.system}.default;
        };

        fonts =
          _: prev: with _; {
            berkeley-mono = callPackage ./packages/fonts/berkeley-mono.nix { secrets = inputs.secrets; };
            commit-mono-nf = callPackage ./packages/fonts/commit-mono-nf.nix { };
          };

        custom-packages =
          _: prev: with _; {
            ocr = callPackage ./packages/ocr/ocr.nix { };
          };

        tweaks = _: prev: {
          mactop = prev.mactop.overrideAttrs (_: {
            version = "2.0.6";
            src = prev.fetchFromGitHub {
              owner = "metaspartan";
              repo = "mactop";
              tag = "v2.0.6";
              hash = "sha256-J+ebxVV5aNTz0qtBkd8G4NX0EB7wWkWIIzS0h/jvQWI=";
            };
            doCheck = false;
          });
        };
      };

      darwinConfigurations = {
        AlexMBP = mkSystem "AlexMBP" {
          system = "aarch64-darwin";
          user = "ale";
          darwin = true;
        };
      };

      nixosConfigurations = {
        nixos-vm-aarch64 = mkSystem "nixos-vm-aarch64" {
          system = "aarch64-linux";
          user = "ale";
        };

        nixos-orbstack = mkSystem "nixos-orbstack" {
          system = "aarch64-linux";
          user = "ale";
        };

        # FIXME: not using mkSystem because using existing home config
        # breaks the installation due to too many files error.
        # This should be fixed in the future when another refactor
        # is done (re-organizing the packages)
        homelab-nuc = inputs.nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.disko.nixosModules.disko
            ./hosts/homelab-nuc
            inputs.nixos-facter-modules.nixosModules.facter
            inputs.agenix.nixosModules.default
            {
              config.facter.reportPath = ./hosts/homelab-nuc/facter.json;
            }
            {
              nixpkgs = nixpkgsDefaults;
            }
          ];
        };
      };
    }
    // inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs-unstable {
          inherit system;
          inherit (nixpkgsDefaults) config;
        };
      in
      {
        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            just
            ssh-copy-id
            claude-code
            nh
            nixfmt-tree
            nixos-rebuild-ng
            inputs.agenix.packages.${system}.default
          ];

          NH_FLAKE = ".";
        };
      }
    );
}
