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
      inherit (inputs.nixpkgs-unstable.lib) attrValues optionalAttrs;

      overlaysList = attrValues self.overlays;

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
        #
        # After all overlays are applied, the following are available:
        # - pkgs.pkgs-master.*     packages from nixpkgs master
        # - pkgs.pkgs-stable.*     packages from nixpkgs 25.05
        # - pkgs.pkgs-unstable.*   packages from nixpkgs unstable
        # - pkgs.pkgs-x86.*        x86_64 packages (Apple Silicon only)
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

        # External flakes below

        zellij-plugins = _: prev: {
          zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;
          zjstatus-hints = inputs.zjstatus-hints.packages.${prev.stdenv.hostPlatform.system}.default;
          zj-quit = inputs.zj-quit.packages.${prev.stdenv.hostPlatform.system}.default;
        };

        custom-packages = _: prev: {
          age-with-plugins = prev.callPackage ./packages/age-with-plugins.nix { };
        };

        # Temporary overlays
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

        homelab-nuc = mkSystem "homelab-nuc" {
          system = "x86_64-linux";
          user = "ale";
          nixos-anywhere = true;
          homeConfig = ./hosts/homelab-nuc/home.nix;
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
