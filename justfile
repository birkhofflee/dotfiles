#!/usr/bin/env just --justfile

# Use bash for better shell features
set shell := ["bash", "-cu"]

# Get the path to this directory
FLAKES_PATH := justfile_directory()

SSH_OPTIONS := "-o PubkeyAuthentication=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
CACHIX_COMMAND := "op plugin run -- cachix"

import 'justfiles/vm-vmware-fusion.just'
import 'justfiles/vm-orbstack.just'

# Overview of justfile
default:
  @echo "Runtime Variables:"
  @echo "    NIXADDR={{NIXADDR}}"
  @echo "    NIXPORT={{NIXPORT}}"
  @echo "    NIXUSER={{NIXUSER}}"
  @echo "    SSH_OPTIONS={{SSH_OPTIONS}}"
  @echo "    FLAKES_PATH={{FLAKES_PATH}}"
  @echo ""
  @just --list

# Formats the entire repo using treefmt-nix
[group('code-quality')]
format:
  nix fmt

alias s := switch
# Switch darwin configuration
[group('darwin')]
switch:
  nh darwin switch --show-trace -- --accept-flake-config

[group('homelab')]
switch-nixos-server:
  nh os switch -H nixos-server-01 --accept-flake-config --target-host nixos-server-01 --build-host nixos-server-01 -e passwordless

[group('homelab')]
switch-nixos-desktop:
  nh os switch -H nixos-desktop-01 --accept-flake-config --target-host root@nixos-desktop-01 --build-host nixos-server-01 -e passwordless

switch-nixos-vps-tw:
  nh os switch -H nixos-vps-tw-01 --accept-flake-config --target-host root@nixos-vps-tw-01 --build-host nixos-server-01 -e passwordless

# Build proxmox VMA image for nixos-desktop-01 on nixos-server-01 (x86_64-linux).
# Syncs the working tree (including uncommitted changes) then builds remotely.
# The dotfiles.secret input is resolved locally (mac has GitHub SSH access) and
# rsynced separately, then injected via --override-input on the remote build.
[group('homelab')]
build-desktop-image:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Syncing dotfiles to nixos-server-01:/tmp/dotfiles-build/ ..."
  rsync -a --delete --exclude '.git' --exclude 'result' {{FLAKES_PATH}}/ ale@nixos-server-01:/tmp/dotfiles-build/
  echo "Resolving secrets store path (requires GitHub SSH access) ..."
  SECRETS_STORE=$(nix flake archive --json '{{FLAKES_PATH}}' | jq -r '.inputs.secrets.path')
  echo "Syncing secrets ($SECRETS_STORE) to nixos-server-01:/tmp/dotfiles-secret/ ..."
  rsync -a --delete "$SECRETS_STORE/" nixos-server-01:/tmp/dotfiles-secret/
  echo "Building VMA image on nixos-server-01..."
  ssh nixos-server-01 -- "cd /tmp/dotfiles-build && nix build 'path:.#packages.x86_64-linux.nixos-desktop-01-image' --override-input secrets 'path:/tmp/dotfiles-secret' --show-trace --accept-flake-config"
  echo ""
  echo "VMA is at /tmp/dotfiles-build/result/ on nixos-server-01."
  echo "To upload to PVE, SSH into nixos-server-01 and run:"
  echo "  rsync -avz /tmp/dotfiles-build/result/*.vma.zst root@homelab-nuc:/var/lib/vz/dump/"

alias o := optimize
# Frees up space by optimizing the Nix Store
[group('nix-misc')]
optimize:
  nh clean all

# Repairs the Nix Store
[group('nix-misc')]
repair:
  nix-store --verify --check-contents --repair

alias u := update
# Updates all flake inputs
[group('flake')]
update:
  nix flake update --commit-lock-file

alias ui := update-input
# Updates a specific input. Usage: `just ui nixpkgs`
[group('flake')]
update-input input:
  nix flake update {{input}} --commit-lock-file

# Edit an agenix secret. Usage: `just edit-secret mysecret.age`
[group('secrets')]
[working-directory: 'secrets']
edit-secret secret_file:
  agenix -e {{secret_file}} --identity <(op read 'op://Personal/id_ed25519/private key?ssh-format=openssh') && git add "{{secret_file}}"

# Rekey all secrets.
[group('secrets')]
[working-directory: 'secrets']
rekey:
  op read 'op://Personal/id_ed25519/private key?ssh-format=openssh' > /tmp/k && agenix -r --identity /tmp/k && rm -f /tmp/k

# Push darwin build artifacts to cachix
[group('cache')]
cache-darwin:
  {{CACHIX_COMMAND}} watch-exec birkhoff -- nix build '.#darwinConfigurations.AlexMBP.config.system.build.toplevel'

