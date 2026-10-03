# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a cross-platform Nix configuration repository supporting both **macOS** (via nix-darwin) and **NixOS**, using Nix flakes for reproducible system configuration. The setup uses a shared home-manager configuration that works across all systems.

**Current hosts:**
- `AlexMBP`: macOS (M1 Pro, Tahoe) - nix-darwin
- `nixos-vm-aarch64`: NixOS (aarch64-linux) - VMware Fusion VM
- `nixos-orbstack`: NixOS (aarch64-linux) - OrbStack VM
- `nixos-server-01`: NixOS (x86_64-linux) - Proxmox VM on homelab server (`homelab-nuc`)
- `nixos-desktop-01`: NixOS (x86_64-linux) - Proxmox VM with GUI (GNOME default, Hyprland specialization)

**Current user:** `ale`

## Architecture

### Repository Structure

```
.
├── flake.nix              # Main flake configuration
├── lib/
│   └── mksystem.nix       # Helper function to create system configurations
├── hosts/                 # System-specific configurations
│   ├── AlexMBP/          # macOS host (nix-darwin)
│   │   ├── default.nix   # System configuration
│   │   ├── home.nix      # macOS-specific home: imports shared home + 1password, ghostty
│   │   ├── os-settings.nix
│   │   ├── age-identity.txt  # 1Password age plugin identity for decryption
│   │   ├── ssh-config.nix    # agenix HM module config + secret declarations
│   │   └── packages/     # homebrew.nix + user-packages.nix
│   ├── nixos-vm-aarch64/ # VMware Fusion NixOS VM
│   │   ├── default.nix   # System configuration
│   │   └── home.nix      # Host-specific home config
│   ├── nixos-orbstack/   # OrbStack NixOS VM
│   │   ├── default.nix
│   │   └── home.nix
│   ├── nixos-server-01/  # Proxmox VM (homelab server)
│   │   ├── default.nix
│   │   ├── disk-config.nix   # disko BTRFS layout
│   │   ├── facter.json       # nixos-facter hardware report (pre-committed)
│   │   ├── home.nix          # Host-specific home config
│   │   └── services/         # tailscale, atuin, rybbit, caddy, cloudflared, apex-discord-bot, jupyter
│   ├── nixos-desktop-01/ # Proxmox VM (GUI desktop)
│   │   ├── default.nix   # Entry point: imports sub-modules + sets stateVersion
│   │   ├── hardware.nix  # Boot, proxmox VM config, zramSwap, enableHardwareAccel option
│   │   ├── networking.nix # Hostname, firewall, tailscale, openssh, SSH host key pre-seeding
│   │   ├── desktop.nix   # GNOME/GDM, dconf HiDPI, GNOME Remote Desktop service, sleep targets
│   │   ├── users.nix     # Users, fonts, system packages, timezone, sudo, i18n
│   │   └── home.nix      # Host-specific home config (CLI/shell tools + 1password, ghostty)
│   ├── common-system-packages.nix  # System packages shared across all hosts
│   └── shared-nix-settings.nix     # Shared Nix daemon settings
├── home/                  # Shared home-manager base (imported by every host's home.nix)
│   ├── default.nix        # Explicit imports of all shared modules + common packages
│   └── modules/           # All home-manager modules (programs + config files)
│       ├── shell/         # Zsh shell scripts (functions.zsh, keys.zsh, fzf.zsh, etc.)
│       └── *.nix          # Per-program configs (git, helix, zsh, atuin, etc.)
├── packages/              # Custom Nix derivations (exposed via custom-packages / python-llm-plugins overlays)
│   ├── age-with-plugins.nix           # age + age-plugin-1p wrapper with umask fix
│   ├── nixos-anywhere-patched.nix     # nixos-anywhere with local patches (see patches/)
│   ├── llm-mlx.nix                    # llm-mlx python package (Darwin only)
│   ├── fonts/                         # berkeley-mono(-variable), commit-mono-nf (secrets-sourced)
│   ├── impbcopy/                      # macOS ObjC tool: copy images to clipboard (used by impaste)
│   ├── ocr/                           # macOS Swift Vision-framework OCR CLI
│   └── patches/                       # Patch files applied by the derivations above
├── secrets/               # agenix-encrypted secrets
│   ├── secrets.nix        # Public key declarations for each secret
│   └── *.age              # Encrypted secret files
└── justfiles/             # Modular just recipes
    ├── vm-vmware-fusion.just  # VMware Fusion VM management
    └── vm-orbstack.just       # OrbStack VM management
```

### Flake Structure

The repository uses a flake-based architecture defined in `flake.nix`:

- **Multiple nixpkgs channels**: `nixpkgs-stable` (25.05-darwin) and `nixpkgs-unstable` (default)
- **Overlays system** (all defined in `flake.nix`, applied via `overlaysList` in `mkSystem`): Provides access to different package versions and custom packages
  - `pkgs-stable`, `pkgs-unstable`: Different nixpkgs versions
  - `nur`: Nix User Repository
  - `claude-code`: `claude-code-nix` overlay (tracks latest Claude Code)
  - `zellij-plugins`: Custom Zellij plugins (zjstatus, zjstatus-hints, zj-quit)
  - `custom-packages`: Local derivations in `packages/` — `age-with-plugins`, `nixos-anywhere` (patched), the fonts (`berkeley-mono`, `berkeley-mono-variable`, `commit-mono-nf`), and `supercharge` (from the `secrets` input)
  - `python-llm-plugins`: Extends `pythonPackagesExtensions` with `llm-mlx` (Darwin only)
  - `tweaks`: Temporary per-package overrides (currently empty — the place to pin/patch a package short-term)
- **lib/mksystem.nix**: Helper function that simplifies creating system configurations for both Darwin and NixOS
- **devShells.default**: Available via `nix develop` - provides `just`, `nh`, `agenix`, `nixos-anywhere`, `ssh-copy-id`, `deploy-rs`, and the treefmt wrapper; sets `NH_FLAKE="."`
- **Formatting**: `nix fmt` (and `just format`) run a treefmt-nix wrapper that formats the **whole repo** (not just Nix). `checks.formatting` enforces it in CI/`nix flake check`.

### Configuration Philosophy

**Separation of Concerns:**
1. **System-level** (`hosts/<hostname>/default.nix`): OS-specific configuration (nix-darwin or NixOS)
2. **User-level** (`home/default.nix`): Shared home-manager configuration, platform-agnostic

The `lib/mksystem.nix` helper abstracts away the differences between Darwin and NixOS configurations, automatically:
- Selecting the correct system function (darwinSystem vs nixosSystem)
- Applying overlays and nixpkgs configuration
- Loading home-manager from `hosts/<hostname>/home.nix` (auto-derived; not configurable)
- Integrating nix-index-database, agenix, and Determinate Nix
- Passing special arguments to modules (`currentSystem`, `currentSystemName`, `currentSystemUser`, `inputs`, `hasDesktop`)
- Optionally including disko and nixos-facter modules when `nixos-anywhere = true`

### Home Configuration (`home/`)

The `home/` directory provides a **shared base** that every host's `home.nix` imports via `../../home`. It is not used directly by mksystem — each host has its own `hosts/<hostname>/home.nix` which imports this shared base plus any host-specific modules (e.g., `1password.nix`, `ghostty.nix`).

- `home/default.nix`: Explicitly imports each shared module from `home/modules/` (not auto-scanned)
- `home/modules/`: All home-manager modules — program configs (e.g., `zsh.nix`, `helix.nix`) and config files live here (previously split between `home/programs/` and `home/files/`)
- `home/modules/shell/`: Zsh shell scripts sourced by `zsh.nix`
- Platform-specific settings use `pkgs.stdenv.hostPlatform.isDarwin` / `pkgs.stdenv.hostPlatform.isLinux` within modules
- macOS activation scripts (Library visibility, restart system services) live in `hosts/AlexMBP/home.nix`
- `hasDesktop` is passed as an extra arg to home-manager (use it to gate GUI-specific config)

### Host Configurations

**AlexMBP** (`hosts/AlexMBP/default.nix`):
- nix-darwin system configuration
- System packages and Homebrew integration
- macOS-specific OS settings and network configuration

**nixos-vm-aarch64** (`hosts/nixos-vm-aarch64/default.nix`):
- NixOS system configuration for VMware Fusion
- Basic bootloader and filesystem configuration
- NixOS-specific settings (networking, SSH, systemd)

**nixos-orbstack** (`hosts/nixos-orbstack/default.nix`):
- NixOS system configuration for OrbStack
- Similar to nixos-vm-aarch64 but optimized for OrbStack environment

**nixos-server-01** (`hosts/nixos-server-01/default.nix`):
- NixOS system configuration for a Proxmox VM running on the `homelab-nuc` PVE host
- Uses `mkSystem` with `nixos-anywhere = true` (enables disko and nixos-facter modules)
- Home config at `hosts/nixos-server-01/home.nix` imports the shared `../../home` base and adds a few extras (glow, just, git-open, gh, nil, yaml-language-server)
- Services: tailscale, atuin, rybbit (analytics), caddy (reverse proxy), cloudflared (tunnel), apex-discord-bot (from the `apex-discord-bot` flake input), jupyter
- Containers (Podman): rybbit-backend, rybbit-client, rybbit-postgres, rybbit-clickhouse, jupyter (scipy-notebook)
- Uses zramSwap for better memory management

**nixos-desktop-01** (`hosts/nixos-desktop-01/default.nix`):
- NixOS Proxmox VM with a full GUI desktop on `homelab-nuc`
- Default desktop: GNOME with GDM and GNOME Remote Desktop (RDP on port 3389)
- Hyprland specialization: selectable at boot; uses wayvnc (VNC on port 5900) for remote access
- Built as a Proxmox VMA image via `packages.x86_64-linux.nixos-desktop-01-image`; use `just build-desktop-image` (builds remotely on nixos-server-01 then rsync to PVE)
- System config split into sub-modules: `hardware.nix`, `networking.nix`, `desktop.nix`, `users.nix`
- SSH host key pre-seeded from `dotfiles.secret` input (required for agenix on first boot)

### Package Management Strategy

**Nix packages** are used for:
- CLI tools and development utilities
- System-level configuration
- Declarative management

**Homebrew** (`hosts/AlexMBP/packages/homebrew.nix`) is used for:
- GUI applications (they self-update and conflict with Nix immutability)
- Mac App Store apps (via `mas`)
- Some specialized tools (displayplacer, borgbackup-fuse)

### Binary Caches

Substituters are declared in three places, and which ones apply depends on **where the build runs**:

1. `flake.nix` `nixConfig.extra-substituters` — nix-community, helix, birkhoff, claude-code. Only honoured by the invoking (local) Nix, and only with `--accept-flake-config` + the user in `trusted-users`.
2. `hosts/shared-nix-settings.nix` — the same four. Imported by every NixOS host, so this is what the **remote daemon** uses.
3. `hosts/AlexMBP/default.nix` `determinateNix.customSettings` — nix-community, helix, birkhoff (`nix.settings` is ignored when `determinateNix.enable = true`).

All use `extra-*` so `cache.nixos.org` is preserved.

Keep sets 1 and 2 in sync. `just deploy-*` (deploy-rs `remoteBuild = true`) and `just switch-nixos-*` (`--build-host`) build on the target/build host, and a flake's `nixConfig` does **not** propagate over SSH to the remote daemon — only `shared-nix-settings.nix` applies there. Adding a cache to `flake.nix` alone has no effect on remote builds.

`just cache-darwin` pushes to `birkhoff.cachix.org`, and pushes **darwin** closures only — Linux hosts get no benefit from it.

**`birkhoff.cachix.org` is world-readable and this repo is public.** Anything pushed is published, so pushes must be filtered: the `PRIVATE_PATHS` variable in the `justfile` excludes store paths built from the private `secrets` input (`berkeley-mono`, which is a paid licensed font, and `supercharge`). `commit-mono-nf` is not excluded — it is OFL and fetched from a public GitHub release. Add to `PRIVATE_PATHS` when adding anything else sourced from `secrets`.

Cachix will not serve a narinfo whose closure is incomplete, so filtering makes the toplevel and the home profile unservable while the individual package paths still substitute normally. Also note Cachix has **no CLI or API for deleting store paths** — `cachix remove` only edits nix.conf. Deletion is web-UI-only at app.cachix.org, so treat a push as irreversible.

Decrypted agenix secrets are never at risk here: they live in `/run/agenix` at activation time, not in the store. What *is* in a NixOS toplevel is `users-groups.json` containing `hashedPassword`.

### Determinate Nix

`flake.nix` tracks the `determinate/3` semver range, so `just update` always moves to the latest 3.x release. How that release reaches each host differs by platform:

**macOS** — the nix-darwin module sets `nix.enable = lib.mkForce false`; it never builds Nix. The running Nix is the installer-managed binary, upgraded imperatively with `sudo determinate-nixd upgrade` (prebuilt download, no compile). The flake input does not control the Mac's Nix version.

**NixOS** — the module sets `nix.package` to the `nix-src` flake output (`modules/nixos.nix:31`). That store path is on neither `cache.nixos.org` nor the public `https://install.determinate.systems` cache (verified with `nix path-info --store`, for both the current and the previously-shipping version — that cache serves installer artifacts, not nix-src flake outputs). The only upstream source is FlakeHub Cache (`https://cache.flakehub.com`), which is **paid and needs imperative per-machine auth** (`determinate-nixd login`; hosts are `logged-out`, and there is no declarative equivalent).

So on NixOS Nix would otherwise be recompiled per host per bump. The workaround is **`just cache-determinate`**: build it once on nixos-server-01 and push the ~130 MiB closure to `birkhoff.cachix.org`, which every host already trusts. Both x86_64-linux NixOS hosts share that one build.

**`just deploy-server` runs `just cache-determinate` automatically as its last step**, so the normal workflow (`just update` → `just deploy-server` → deploy the others) never recompiles Nix more than once. Deploy the server first: `deploy-desktop` builds on the target (deploy-rs `remoteBuild = true`) and would otherwise recompile it. The `switch-nixos-*` recipes use `--build-host nixos-server-01` and already share one build.

The build and the push both run on nixos-server-01 — nothing is copied back to the Mac. The cachix token is the agenix secret `secrets/cachix-token.age`, declared in `hosts/nixos-server-01/default.nix` (owner `ale`, mode `0400`, mounted at `/run/agenix/cachix-token`), and `pkgs.cachix` is in that host's `systemPackages`. The recipe reads the token into `CACHIX_AUTH_TOKEN` on the far side, so it never crosses the wire. Because the push is now server-side, extending it to whole system closures is just a matter of changing what gets piped into `cachix push`.

The remote command runs `bash -eo pipefail` without `-u`: NixOS's `/etc/bashrc` is sourced for non-interactive shells and is not `set -u` clean.

Do not add `inputs.determinate.inputs.nixpkgs.follows` — upstream warns it causes cache misses for FlakeHub Cache artifacts.

Note that on NixOS the Determinate module retargets the generated `nix.conf` to `/etc/nix/nix.custom.conf` (`modules/nixos.nix:77`), which determinate-nixd includes — so `nix.settings` from `shared-nix-settings.nix` does still take effect.

## Common Development Commands

### Building and Switching Configurations

Using `just` (preferred):
```bash
just switch                 # Build and switch to new configuration (alias: just s)
just switch-nixos-server    # Switch nixos-server-01 remotely via nh os switch
just switch-nixos-desktop   # Switch nixos-desktop-01 remotely via nh os switch
just deploy-server          # Deploy nixos-server-01 via deploy-rs (with magic rollback)
just deploy-desktop         # Deploy nixos-desktop-01 via deploy-rs (with magic rollback)
just deploy-all             # Deploy all NixOS hosts via deploy-rs
just build-desktop-image    # Build Proxmox VMA for nixos-desktop-01 (runs on nixos-server-01)
just update                 # Update all flake inputs and commit lock file (alias: just u)
just update-input <name>    # Update specific flake input (alias: just ui)
just format                 # Format the whole repo via treefmt-nix (nix fmt)
just optimize               # Clean old generations and optimize store (alias: just o)
just repair                 # Verify and repair Nix store
just cache-darwin           # Push darwin build artifacts to cachix
just edit-secret <file.age> # Edit an agenix secret (uses 1Password for identity)
just rekey                  # Rekey all secrets with the 1Password identity
```

**deploy-rs vs nh**: `deploy-*` commands use deploy-rs (remote builds, magic rollback on failure). `switch-nixos-*` commands use `nh os switch` (simpler, no rollback). Prefer `deploy-*` for production homelab hosts.

Using `nh` directly (from repo root, NH_FLAKE="."):
```bash
nh darwin switch --show-trace -- --accept-flake-config
nh clean all
```

### Testing Configuration Changes

Before switching (macOS):
```bash
nix build ".#darwinConfigurations.AlexMBP.system" --show-trace
```

For NixOS (evaluation only from macOS):
```bash
nix eval ".#nixosConfigurations.nixos-vm-aarch64.config.system.name"
nix eval ".#nixosConfigurations.nixos-orbstack.config.system.name"
nix eval ".#nixosConfigurations.nixos-server-01.config.system.name"
```

> **Note:** `nix build "."` uses the git index (staged files only). If you have unstaged modifications, use `nix build "path:.#..."` to include working tree changes.

After switching, verify services are running correctly and check for any activation errors.

### VM Management

**VMware Fusion VM** (`justfiles/vm-vmware-fusion.just`):
```bash
# Bootstrap a fresh NixOS ISO (run once with root password 'root')
just vm-bootstrap0 <ip-address>

# Finalize installation (copy config, switch, setup secrets)
just vm-bootstrap <ip-address>

# SSH into the VM
just vm-ssh           # as user 'ale'
just vm-ssh root      # as root

# Sync dotfiles to VM
NIXADDR=<ip> just vm-sync

# Rebuild NixOS on VM
NIXADDR=<ip> just vm-switch
```

**OrbStack VM** (`justfiles/vm-orbstack.just`):
```bash
# Create OrbStack VM
just orb-create

# Configure NixOS on OrbStack VM
just orb-configure

# Remove OrbStack VM
just orb-remove
```

Environment variables for VMware VM commands:
- `NIXADDR`: VM IP address (required)
- `NIXPORT`: SSH port (default: 22)
- `NIXUSER`: SSH user (default: ale)

**Homelab NixOS Provisioning** (using nixos-anywhere):

See `docs/deployment-instructions-nixos-server.md` for the full step-by-step procedure. Key points:

- The PVE host (`homelab-nuc`) is used as a ProxyJump host to reach the VM at `192.168.1.8`
- SSH host keys must be **pre-generated** and injected via `--extra-files` so agenix secrets can be encrypted to the new host before installation
- The NixOS installer's `/etc/nix/nix.conf` is read-only; pass binary caches via `--option extra-substituters` and `--option extra-trusted-public-keys` directly to nixos-anywhere
- New files must be `git add`-ed (staged) before running nixos-anywhere, since nix evaluates from the git index
- After reinstall, the Tailscale auth key must be rotated (single-use keys are consumed on first boot) and deployed via `nh os switch`

```bash
# After initial provisioning or config changes:
just switch-nixos-server
```

## File Organization Patterns

### Adding New Programs to Home Configuration

1. Create `home/modules/<program>.nix`
2. Add the import explicitly to `home/default.nix` (imports are not auto-scanned)
3. For programs that only belong on specific hosts (e.g., GUI apps), add the import to `hosts/<hostname>/home.nix` instead of the shared `home/default.nix`
4. Use `pkgs.stdenv.hostPlatform.isDarwin` / `pkgs.stdenv.hostPlatform.isLinux` within the module for platform-specific settings, or use `hasDesktop` (passed as `extraSpecialArgs`) to gate desktop-only config

Example shared module:
```nix
{ pkgs, lib, ... }:
{
  programs.myprogram = {
    enable = true;
  } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    # macOS-specific settings
  };
}
```

### Adding Shell Configuration

1. Add a new `.zsh` file to `home/modules/shell/` for shell scripts
2. It will be symlinked to `~/.shell/` automatically (see `home.file.".shell".source = ./shell` in `zsh.nix`)
3. Source it explicitly in `home/modules/zsh.nix` if needed, or drop it alongside other scripts that are sourced via glob

### Adding Custom Packages

1. **System packages** (shared across hosts): Edit `hosts/common-system-packages.nix`
2. **System packages** (OS-specific): Edit `hosts/<hostname>/default.nix` or a sub-module
3. **User packages** (shared home): Add inline to `home.packages` in `home/default.nix`
4. **User packages** (host-specific): Edit `hosts/<hostname>/packages/user-packages.nix`
5. **Homebrew apps** (macOS only): Edit `hosts/AlexMBP/packages/homebrew.nix`
6. **Custom derivations**: Create in `packages/` directory and add to overlays in `flake.nix`

### Adding a New Host

1. Create `hosts/<hostname>/default.nix` with system configuration
2. Create `hosts/<hostname>/home.nix` — **required** by mksystem.nix (auto-derived, not configurable). It should import `../../home` for the shared base plus any host-specific modules
3. Use `currentSystemUser` parameter (provided by mksystem.nix) instead of hardcoding username
4. Import shared configuration files as needed:
   - `../shared-nix-settings.nix`: Common Nix daemon settings
   - `../common-system-packages.nix`: Common system packages
5. Add to `flake.nix`:
   ```nix
   # For macOS (darwin is auto-detected from system suffix)
   darwinConfigurations.<hostname> = mkSystem "<hostname>" {
     system = "aarch64-darwin";
     user = "ale";
     hasDesktop = true;  # optional: passed to home-manager as extraSpecialArgs
   };

   # For NixOS (standard)
   nixosConfigurations.<hostname> = mkSystem "<hostname>" {
     system = "aarch64-linux";  # or "x86_64-linux"
     user = "ale";
   };

   # For NixOS with nixos-anywhere (disko + nixos-facter)
   nixosConfigurations.<hostname> = mkSystem "<hostname>" {
     system = "x86_64-linux";
     user = "ale";
     nixos-anywhere = true;
   };
   ```
   Note: when `nixos-anywhere = true`, `hosts/<hostname>/facter.json` must exist (generated with `--generate-hardware-config nixos-facter`). mksystem.nix throws if it's missing.

   For Proxmox VM image builds (like `nixos-desktop-01`), no `nixos-anywhere = true` is needed — the host uses `proxmox-image.nix` and a VMA is built via:
   ```nix
   packages.x86_64-linux.<hostname>-image = self.nixosConfigurations.<hostname>.config.system.build.VMA;
   ```
   Use `just build-desktop-image` as a template for the remote-build workflow.

## Important Implementation Details

### Justfile Architecture

The repository uses a modular `justfile` system where the main `justfile` at the root imports specialized recipe files from `justfiles/`:

- Main `justfile`: Core commands (switch, update, format, clean, cache)
- `justfiles/vm-vmware-fusion.just`: VMware Fusion VM management recipes
- `justfiles/vm-orbstack.just`: OrbStack VM management recipes

When adding new VM-related or specialized commands, create a new `.just` file in `justfiles/` and import it in the main `justfile` using `import 'justfiles/<name>.just'`.

**Justfile groups** organize commands:
- `darwin`: macOS-specific commands (switch)
- `homelab`: Homelab server commands (switch-nixos-*, deploy-*, build-desktop-image)
- `flake`: Flake management (update, update-input)
- `nix-misc`: Nix store maintenance (optimize, repair)
- `cache`: Cachix operations (cache-darwin)
- `code-quality`: Code formatting (format)
- `secrets`: Secret management (edit-secret)

### Overlay System

When adding packages from different nixpkgs versions, use the overlay system:
- `pkgs-stable.<package>` for stable releases
- `pkgs-unstable.<package>` for unstable packages (this is the default `pkgs`)

### Secrets Management

Secrets are managed with **agenix** (age-encrypted secrets checked into git).

- **`secrets/secrets.nix`**: Declares which public keys can decrypt each `.age` file. The `ale` key is the SSH ed25519 public key corresponding to the 1Password identity.
- **`secrets/*.age`**: Encrypted secret files (ssh-config, tailscale authkey, cloudflared credentials, etc.).
- **`hosts/AlexMBP/age-identity.txt`**: The `AGE-PLUGIN-1P` identity used to decrypt secrets on AlexMBP. This is host-specific and lives alongside the agenix config.
- **`hosts/AlexMBP/ssh-config.nix`**: Configures the agenix home-manager module — sets `age.package`, `age.identityPaths`, declares secrets, and overrides the launchd agent's `KeepAlive` (removing `Crashed = false` which would otherwise cause the agent to loop on every clean exit).
- **`packages/age-with-plugins.nix`**: Custom `age` derivation that wraps `age-plugin-1p` with a `umask 077` reset before exec. Required because the agenix mount-secrets script sets `umask u=r,g=,o=` in a subshell, which would otherwise cause `op` to create its session file as `0400` (breaking subsequent invocations).

To edit a secret (uses 1Password for the decryption identity):
```bash
just edit-secret <file.age>   # runs from secrets/ directory
```

A private `dotfiles.secret` flake input is also referenced for sensitive files requiring SSH credentials to access.

### Homelab-Specific Architecture

The `nixos-server-01` host is a Proxmox VM on the `homelab-nuc` PVE host. It uses `mkSystem` with `nixos-anywhere = true`:
- **Home config**: `hosts/nixos-server-01/home.nix` imports the shared `home/` base plus a small set of host extras
- **Uses nixos-anywhere**: Automated remote installation with disk partitioning (disko)
- **Uses nixos-facter**: Hardware config via `hosts/nixos-server-01/facter.json` (pre-committed; do not regenerate unless hardware changes)
- **Remote deployment**: `just switch-nixos-server` uses `nh os switch` targeting `nixos-server-01` via Tailscale
- **Secrets**: agenix secrets in `secrets/` are encrypted to both the `ale` key (1Password) and the server's SSH host key. When reinstalling, the host key changes — update `secrets/secrets.nix` and rekey with `just rekey` before running nixos-anywhere

### Activation Scripts

The system uses activation scripts at multiple levels:

**System-level** (e.g., `hosts/AlexMBP/default.nix` for macOS):
- `preActivation`: Homebrew check
- `postActivation`: Enable locate database, reveal /Volumes

**Home-level** (`hosts/AlexMBP/home.nix`):
- `revealHomeLibraryDirectory`: Make ~/Library visible
- `activateUserSettings`: Restart macOS system services to apply settings

Order matters: home-manager activation scripts use `lib.hm.dag.entryAfter` to ensure correct sequencing.

### Shell Configuration

The shell setup uses several specialized files (all under `home/modules/shell/`):
- `functions.zsh`: Custom functions (shrinkvid, impaste, timer, aic, gg, s, nr, ns)
- `keys.zsh`: Custom Zsh keybindings (Ctrl+U, Alt+Q, Alt+Shift+S, etc.)
- `fzf.zsh`: fzf-tab configuration with smart previews
- `proxy.zsh`: Auto-propagated proxy settings from macOS system preferences
- `completions.zsh`: Custom completions
- `options.zsh`: Zsh options
- `colors.zsh`: Color definitions
- `op.zsh`: 1Password shell integration
- `utilities/`: Additional shell utility scripts

These are symlinked to `~/.shell/` and sourced in `home/modules/zsh.nix`.

### Development Environments

As noted in the README: "Development Environments should be managed using nix-shell" rather than installing development tools globally. Use `nix-shell -p <packages>` for temporary environments or create `shell.nix` files for projects.

The `nix-index-database` and `comma` are configured to help locate and run commands without installation.

## Troubleshooting

### After macOS Updates

1. `xcode-select --install` — upgrade Xcode CLI tools
2. May need to uninstall and reinstall Nix (use the official installer, not the pkg)
3. System restart may be required before `just switch` works
4. If SSL errors appear, source `/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
5. Review nix-darwin CHANGELOG for breaking changes

### Nix Store Issues

```bash
just repair  # Verify and repair Nix store
```

### Build Failures

`just switch` already includes `--show-trace`. For manual builds:
```bash
nix build ".#darwinConfigurations.AlexMBP.system" --show-trace
```
