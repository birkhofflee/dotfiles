{
  description = "birkhoff's dotfiles";

  nixConfig = {
    # Merged with the system-level substituters.
    # This config is included to speed up the initial build.
    # trusted-user config is required
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://helix.cachix.org"
      "https://birkhoff.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "birkhoff.cachix.org-1:m7WmdU7PKc6fsKedC278lhLtiqjz6ZUJ6v2nkVGyJjQ="
    ];
  };

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # For provisioning NixOS machines with nixos-anywhere
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs-unstable";
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

    apex-discord-bot.url = "github:birkhofflee/apex-discord-bot";
    apex-discord-bot.inputs.nixpkgs.follows = "nixpkgs-unstable";
    apex-discord-bot.inputs.flake-utils.follows = "flake-utils";

    i915-sriov-dkms.url = "github:strongtz/i915-sriov-dkms";
    i915-sriov-dkms.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs =
    {
      self,
      ...
    }@inputs:
    # https://github.com/malob/nixpkgs/blob/61d4809925a523296278885ff8a75d3776a5c813/flake.nix#L34
    let
      inherit (inputs.nixpkgs-unstable.lib) attrValues;

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
        zellij-plugins = _: prev: {
          zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;
          zjstatus-hints = inputs.zjstatus-hints.packages.${prev.stdenv.hostPlatform.system}.default;
          zj-quit = inputs.zj-quit.packages.${prev.stdenv.hostPlatform.system}.default;
        };

        custom-packages = _: prev: {
          age-with-plugins = prev.callPackage ./packages/age-with-plugins.nix { };
          nixos-anywhere = prev.callPackage ./packages/nixos-anywhere-patched.nix {
            nixos-anywhere = inputs.nixos-anywhere.packages.${prev.stdenv.hostPlatform.system}.nixos-anywhere;
          };
          berkeley-mono = prev.callPackage ./packages/fonts/berkeley-mono.nix { secrets = inputs.secrets; };
          berkeley-mono-variable = prev.callPackage ./packages/fonts/berkeley-mono-variable.nix { secrets = inputs.secrets; };
          commit-mono-nf = prev.callPackage ./packages/fonts/commit-mono-nf.nix { };
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
          hasDesktop = true;
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

        nixos-server-01 = mkSystem "nixos-server-01" {
          system = "x86_64-linux";
          user = "ale";
          nixos-anywhere = true;
        };

        nixos-desktop-01 = mkSystem "nixos-desktop-01" {
          system = "x86_64-linux";
          user = "ale";
          hasDesktop = true;
        };

        nixos-vps-tw-01 = mkSystem "nixos-vps-tw-01" {
          system = "x86_64-linux";
          user = "ale";
        };
      };

      packages.x86_64-linux.nixos-desktop-01-image =
        self.nixosConfigurations.nixos-desktop-01.config.system.build.VMA;
    }
    // inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs-unstable {
          inherit system;
          inherit (nixpkgsDefaults) config overlays;
        };
      in
      {
        devShells.default =
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
            packages = with pkgs; [
              just
              ssh-copy-id
              nh
              nixfmt-tree
              nixos-anywhere
              agenix
            ];

            NH_FLAKE = ".";
          };
      }
    );
}
