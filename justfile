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

# Formats the entire repo using nixfmt-tree
[group('code-quality')]
format:
  treefmt

alias s := switch
# Switch darwin configuration
[group('darwin')]
switch:
  nh darwin switch --show-trace -- --accept-flake-config

alias sf := switch-fast
# Switch darwin configuration with --offline flag
[group('darwin')]
switch-fast:
  nh darwin switch --show-trace --offline -- --accept-flake-config

# Switch homelab (NixOS) configuration with nixos-rebuild-ng
# because neither nh or nixos-rebuild works.
#
# The binary name is `nixos-rebuild`
#
# @see https://github.com/NixOS/nixpkgs/issues/439945
[group('homelab')]
switch-homelab:
  nh os switch -H nixos-server-01 --accept-flake-config --target-host nixos-server-01 --build-host nixos-server-01 -e passwordless

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
  agenix -e {{secret_file}} --identity <(op read 'op://Personal/id_ed25519/private key?ssh-format=openssh')

# Rekey all secrets.
[group('secrets')]
[working-directory: 'secrets']
rekey:
  op read 'op://Personal/id_ed25519/private key?ssh-format=openssh' > /tmp/k && agenix -r --identity /tmp/k && rm -f /tmp/k

# Push darwin build artifacts to cachix
[group('cache')]
cache-darwin:
  {{CACHIX_COMMAND}} watch-exec birkhoff -- nix build '.#darwinConfigurations.AlexMBP.config.system.build.toplevel'

