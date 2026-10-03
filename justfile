#!/usr/bin/env just --justfile

# Use bash for better shell features
set shell := ["bash", "-cu"]

# Get the path to this directory
FLAKES_PATH := justfile_directory()

SSH_OPTIONS := "-o PubkeyAuthentication=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
CACHIX_COMMAND := "op plugin run -- cachix"

# birkhoff.cachix.org is world-readable, so anything pushed to it is published. These are the
# store path name fragments built from the private `secrets` input — Berkeley Mono is a paid,
# licensed font and supercharge is private — and they must never be pushed. "berkeley-mono"
# also covers berkeley-mono-variable. commit-mono-nf is deliberately absent: it is OFL and
# fetched from a public GitHub release.
PRIVATE_PATHS := "berkeley-mono|supercharge"

# nh injects `-o ControlMaster=auto -o ControlPath=/tmp/nh-ssh-<pid>/ssh-%n
# -o ControlPersist=60` into NIX_SSHOPTS for every `--build-host` run. Its
# `nix copy --to` and the remote build establish and then reuse that master,
# and by the time `nix copy --from` runs, reading the multiplexed channel
# yields the wrong stream: nix takes the first 8 bytes as the daemon magic
# number, gets `started\n`, and dies with
#
#   error: cannot open connection to remote store 'ssh-ng://nixos-server-01':
#   error: protocol mismatch, got 'started
#
# It is deterministic, not a flake, and it aborts the deploy after the remote
# build has already succeeded. Turning multiplexing off avoids it: nh prepends
# whatever NIX_SSHOPTS already contains to its own flags, and ssh uses the
# first occurrence of any given option, so these win.
NO_SSH_MUX := "NIX_SSHOPTS='-o ControlMaster=no -o ControlPath=none'"

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
  {{NO_SSH_MUX}} nh os switch -H nixos-server-01 --accept-flake-config --target-host nixos-server-01 --build-host nixos-server-01 -e passwordless

[group('homelab')]
switch-nixos-desktop:
  {{NO_SSH_MUX}} nh os switch -H nixos-desktop-01 --accept-flake-config --target-host root@nixos-desktop-01 --build-host nixos-server-01 -e passwordless

# Deploy nixos-server-01 via deploy-rs (remote build, magic rollback), then cache Determinate Nix
[group('homelab')]
deploy-server:
  deploy .#nixos-server-01
  just cache-determinate

# Deploy nixos-desktop-01 via deploy-rs (remote build, magic rollback)
[group('homelab')]
deploy-desktop:
  deploy .#nixos-desktop-01

# Deploy all NixOS hosts via deploy-rs
[group('homelab')]
deploy-all:
  deploy .

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
  agenix -e {{secret_file}} --identity <(op read 'op://Private/id_ed25519/private key?ssh-format=openssh') && git add "{{secret_file}}"

# Rekey all secrets.
[group('secrets')]
[working-directory: 'secrets']
rekey:
  op read 'op://Private/id_ed25519/private key?ssh-format=openssh' > /tmp/k && agenix -r --identity /tmp/k && rm -f /tmp/k

# Push darwin build artifacts to cachix, minus anything from the private `secrets` input
[group('cache')]
cache-darwin:
  #!/usr/bin/env bash
  set -euo pipefail
  # Pushes the full closure, not just newly-built paths, with {{PRIVATE_PATHS}} filtered out.
  # Consequence: cachix refuses to serve a narinfo whose closure is incomplete, so the toplevel
  # and the home profile (which reference the fonts) will not be servable. That is intended —
  # the value here is the individual package paths, which still substitute normally.
  nix build '.#darwinConfigurations.AlexMBP.config.system.build.toplevel' --print-out-paths --no-link \
    | xargs nix path-info --recursive \
    | grep -vE '{{PRIVATE_PATHS}}' \
    | {{CACHIX_COMMAND}} push birkhoff

# Build Determinate Nix for x86_64-linux on nixos-server-01 and push it to cachix
[group('cache')]
cache-determinate:
  #!/usr/bin/env bash
  set -euo pipefail
  # The Determinate NixOS module sets nix.package to a nix-src flake output that is on
  # neither cache.nixos.org nor install.determinate.systems — only on the paid FlakeHub
  # Cache. Without this, every NixOS host recompiles Nix (~130 MiB closure) whenever the
  # `determinate` input is bumped. `deploy-server` runs this automatically, so the desktop
  # substitutes it from birkhoff.cachix.org instead of recompiling. Both NixOS hosts are
  # x86_64-linux, so one build covers them all.
  #
  # Builds and pushes entirely on nixos-server-01: the cachix token is an agenix secret at
  # /run/agenix/cachix-token (declared in hosts/nixos-server-01/default.nix, owned by ale), so
  # it is read into the environment on the far side and never crosses the wire. After the
  # first run this is nearly a no-op — cachix skips paths it already has.
  src=$(jq -r '.nodes.nix.locked.url' {{FLAKES_PATH}}/flake.lock)
  case "$src" in
    *nix-src*) ;;
    *) echo "error: flake.lock node 'nix' is not nix-src (got: $src)" >&2; exit 1 ;;
  esac
  echo "Building determinate-nix (x86_64-linux) and pushing from nixos-server-01 ..."
  # No `-u` on the far side: NixOS's /etc/bashrc is not set -u clean and gets sourced here.
  ssh nixos-server-01 -- "bash -eo pipefail -c '
    if [ ! -r /run/agenix/cachix-token ]; then
      echo \"error: /run/agenix/cachix-token not readable — deploy the host first\" >&2; exit 1
    fi
    export CACHIX_AUTH_TOKEN=\$(cat /run/agenix/cachix-token)
    nix build --no-link --print-out-paths \"$src#packages.x86_64-linux.default\" \
      | xargs nix path-info --recursive \
      | cachix push birkhoff
  '"

