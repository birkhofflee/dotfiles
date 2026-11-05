# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a cross-platform Nix configuration repository supporting both **macOS** (via nix-darwin) and **NixOS**, using Nix flakes for reproducible system configuration. The setup uses a shared home-manager configuration that works across all systems.

**Current hosts:**
- `AlexMBP`: macOS (M1 Pro, Tahoe) - nix-darwin
- `nixos-desktop-01`: NixOS (x86_64-linux) - Proxmox VM with GUI (GNOME)

**Not configured here:** `nixos-server-01` (x86_64-linux, Proxmox VM on
`homelab-nuc`) moved to `~/Documents/Infrastructure/Homelab`. This repo still
*depends* on it — `nixos-desktop-01` forwards every build to it and
`just cache-determinate` builds and pushes there — but no longer defines it.

**Current user:** `ale`

**Downstream consumers:** `~/Documents/Infrastructure/Homelab` and
`~/Documents/Infrastructure/Proxy` take this flake as their `dotfiles` input.
They import `home/`, `hosts/shared-nix-settings.nix` and
`hosts/common-system-packages.nix`, apply the whole overlay set, `follows` this
flake's inputs, and reach for its inputs by name through
`inputs.dotfiles.inputs // inputs` in their own `lib/mksystem.nix`. Search both
repos before removing or renaming any of these: nothing fails here, they fail at
their next `just sync-dotfiles`.

## Architecture

### Repository Structure

```
.
├── flake.nix              # Main flake configuration
├── lib/
│   ├── mksystem.nix       # Helper function to create system configurations
│   ├── keys.nix           # Public SSH keys shared across the repo
│   └── caches.nix         # Binary caches for every host's Nix daemon
├── hosts/                 # System-specific configurations
│   ├── AlexMBP/          # macOS host (nix-darwin)
│   │   ├── default.nix   # System configuration
│   │   ├── home.nix      # macOS-specific home: imports shared home + 1password, ghostty
│   │   ├── os-settings/  # default.nix imports the per-area macOS defaults modules
│   │   ├── age-identity.txt  # 1Password age plugin identity for decryption
│   │   ├── ssh-config.nix    # agenix HM module config + secret declarations
│   │   └── packages/     # homebrew.nix + user-packages.nix
│   ├── nixos-desktop-01/ # Proxmox VM (GUI desktop)
│   │   ├── default.nix   # Entry point: imports sub-modules + sets stateVersion
│   │   ├── hardware.nix  # Boot, proxmox VM config, zramSwap
│   │   ├── networking.nix # Hostname, firewall, tailscale, openssh, SSH host key pre-seeding
│   │   ├── desktop.nix   # GNOME/GDM, dconf HiDPI, GNOME Remote Desktop service, sleep targets
│   │   ├── users.nix     # Users, fonts, system packages, timezone, sudo, i18n
│   │   ├── remote-builder.nix # Forwards every build to nixos-server-01
│   │   ├── programs/1password.nix # 1Password CLI + GUI (NixOS modules)
│   │   └── home.nix      # Host-specific home config (imports shared home + 1password, ghostty; firefox)
│   ├── common-system-packages.nix  # System packages shared across all hosts
│   └── shared-nix-settings.nix     # Shared Nix daemon settings
├── home/                  # Shared home-manager base (imported by every host's home.nix)
│   ├── default.nix        # Explicit imports of all shared modules + common packages
│   └── modules/           # All home-manager modules (programs + config files)
│       ├── shell/         # Zsh shell scripts (functions.zsh, keys.zsh, fzf.zsh, etc.)
│       └── *.nix          # Per-program configs (git, helix, zsh, atuin, etc.)
├── packages/              # Custom Nix derivations (exposed via custom-packages / python-llm-plugins overlays)
│   ├── age-with-plugins.nix           # age + age-plugin-1p wrapper with umask fix
│   ├── llm-mlx.nix                    # llm-mlx python package (Darwin only)
│   ├── fonts/                         # berkeley-mono(-variable) (secrets-sourced), commit-mono-nf (public release)
│   ├── impbcopy/                      # macOS ObjC tool: copy images to clipboard (used by impaste)
│   └── ocr/                           # macOS Swift Vision-framework OCR CLI
└── secrets/               # agenix-encrypted secrets
    ├── agenix-rules.nix   # Public key declarations for each secret
    └── *.age              # Encrypted secret files
```

### Flake Structure

The repository uses a flake-based architecture defined in `flake.nix`:

- **nixpkgs**: `nixpkgs-unstable` is what every host and `pkgs` use.
- **Overlays system** (all defined in `flake.nix`, applied via `overlaysList` in `mkSystem`): Provides custom packages
  - `claude-code`: `claude-code-nix` overlay (tracks latest Claude Code)
  - `custom-packages`: Local derivations in `packages/` — `age-with-plugins`, the fonts (`berkeley-mono`, `berkeley-mono-variable`, `commit-mono-nf`), and `supercharge` (from the `secrets` input)
  - `python-llm-plugins`: Extends `pythonPackagesExtensions` with `llm-mlx` (Darwin only)
- **lib/mksystem.nix**: Helper function that simplifies creating system configurations for both Darwin and NixOS
- **devShells.default**: Available via `nix develop` - provides `just`, `nh`, `cachix`, `attic-client`, `agenix`, `ssh-copy-id`, `deploy-rs`, and `nixfmt-tree`; sets `NH_FLAKE="."`
- **Formatting**: `nix fmt` (and `just format`) run nixpkgs' `nixfmt-tree`. The `nixfmt` pre-commit hook enforces it, including in `nix flake check`.
- **Pre-commit hooks** ([git-hooks.nix](https://github.com/cachix/git-hooks.nix), `preCommitCheck` in `flake.nix`): `nixfmt` (RFC 166), `deadnix` and `statix`. Entering the devShell (`direnv` via `.envrc`, or `nix develop`) installs `.git/hooks/pre-commit` and symlinks the gitignored `.pre-commit-config.yaml`; the same hooks run tree-wide as `checks.<system>.pre-commit-check` (`just lint`). statix reads `statix.toml`, which disables only `repeated_keys` (it rejects the dotted `home.packages = …; home.file = …;` style). Use `_:` rather than `{ ... }:` for modules that take no arguments, and drop unused lambda args (e.g. `mkDerivation (finalAttrs: …)` when `finalAttrs` is unused) — deadnix runs with `--fail`. Bypass once with `git commit --no-verify`.

### Configuration Philosophy

**Separation of Concerns:**
1. **System-level** (`hosts/<hostname>/default.nix`): OS-specific configuration (nix-darwin or NixOS)
2. **User-level** (`home/default.nix`): Shared home-manager configuration, platform-agnostic

The `lib/mksystem.nix` helper abstracts away the differences between Darwin and NixOS configurations, automatically:
- Selecting the correct system function (darwinSystem vs nixosSystem)
- Applying overlays and nixpkgs configuration
- Loading home-manager from `hosts/<hostname>/home.nix` (auto-derived; not configurable)
- Integrating nix-index-database, agenix, and Determinate Nix
- Passing special arguments to modules (`currentSystemName`, `currentSystemUser`, `inputs`, `hasDesktop`)

### Home Configuration (`home/`)

The `home/` directory provides a **shared base** that every host's `home.nix` imports via `../../home`. It is not used directly by mksystem — each host has its own `hosts/<hostname>/home.nix` which imports this shared base plus any host-specific modules (e.g., `1password.nix`, `ghostty.nix`).

- `home/default.nix`: Explicitly imports each shared module from `home/modules/` (not auto-scanned)
- `home/modules/`: All home-manager modules — program configs (e.g., `zsh.nix`, `helix.nix`) and config files
- `home/modules/shell/`: Zsh shell scripts sourced by `zsh.nix`
- Platform-specific settings use `pkgs.stdenv.hostPlatform.isDarwin` / `pkgs.stdenv.hostPlatform.isLinux` within modules
- macOS activation scripts (Library visibility, restart system services) live in `hosts/AlexMBP/home.nix`
- `hasDesktop` is passed as an extra arg to home-manager (use it to gate GUI-specific config)

### Host Configurations

**AlexMBP** (`hosts/AlexMBP/default.nix`):
- nix-darwin system configuration
- System packages and Homebrew integration
- macOS-specific OS settings and network configuration

**nixos-desktop-01** (`hosts/nixos-desktop-01/default.nix`):
- NixOS Proxmox VM with a full GUI desktop on `homelab-nuc`
- Default desktop: GNOME with GDM and GNOME Remote Desktop (RDP on port 3389)
- A Hyprland specialisation is sketched as a commented-out block in `desktop.nix`; it is not active
- Built as a Proxmox VMA image via `packages.x86_64-linux.nixos-desktop-01-image`; use `just build-desktop-image` (builds remotely on nixos-server-01 then rsync to PVE)
- System config split into sub-modules: `hardware.nix`, `networking.nix`, `desktop.nix`, `users.nix`, `remote-builder.nix`, `programs/1password.nix`
- SSH host key pre-seeded from `dotfiles.secret` input (required for agenix on first boot)

### Package Management Strategy

**Nix packages** are used for:
- CLI tools and development utilities
- System-level configuration
- Declarative management

**Homebrew** (`hosts/AlexMBP/packages/homebrew.nix`) is used for:
- GUI applications (they self-update and conflict with Nix immutability)
- Mac App Store apps (via `mas`)
- Some specialized tools (displayplacer, screenresolution, apfel, xcodegen)

### Binary Caches

Substituters are declared in two places, and which one applies depends on **where the build runs**:

1. `flake.nix` `nixConfig.extra-substituters` — nix-community, helix, birkhoff, claude-code. Only honoured by the invoking (local) Nix, and only with `--accept-flake-config` + the user in `trusted-users`. It has to be a literal, so it can't import the list below.
2. `lib/caches.nix` — the same four, for every host's daemon. `hosts/shared-nix-settings.nix` applies it on NixOS, so this is what the **remote daemon** uses. `hosts/AlexMBP/default.nix` applies it through `determinateNix.customSettings`, because `nix.settings` is ignored when `determinateNix.enable = true`.

All use `extra-*` so `cache.nixos.org` is preserved.

Keep the two lists in sync. `just deploy-*` (deploy-rs `remoteBuild = true`) and `just switch-nixos-*` (`--build-host`) build on the target/build host, and a flake's `nixConfig` does **not** propagate over SSH to the remote daemon — only `lib/caches.nix` applies there. Adding a cache to `flake.nix` alone has no effect on remote builds.

`just cache-darwin` pushes to `birkhoff.cachix.org`, and pushes **darwin** closures only — Linux hosts get no benefit from it.

`just cache-attic` pushes the full darwin closure, private paths and all, to the Attic cache on the `attic` LXC (configured in `~/Documents/Infrastructure/Homelab`). It exists only to bootstrap a new or reinstalled Mac, through the `--option` flags in the README, so it is deliberately in neither substituter list above. The cache is public but reachable only from the LAN and the tailnet. Its retention is 1 year and only downloads count as access: a push skips paths already there, so paths left untouched for a year are dropped, and go back at the next push. Push at least once within that year, or the cache empties.

**`birkhoff.cachix.org` is world-readable and this repo is public.** Anything pushed is published, so pushes must be filtered: the `PRIVATE_PATHS` variable in the `justfile` excludes store paths built from the private `secrets` input (`berkeley-mono`, which is a paid licensed font, and `supercharge`). `commit-mono-nf` is not excluded — it is OFL and fetched from a public GitHub release. Add to `PRIVATE_PATHS` when adding anything else sourced from `secrets`.

Cachix will not serve a narinfo whose closure is incomplete, so filtering makes the toplevel and the home profile unservable while the individual package paths still substitute normally. Also note Cachix has **no CLI or API for deleting store paths** — `cachix remove` only edits nix.conf. Deletion is web-UI-only at app.cachix.org, so treat a push as irreversible.

Decrypted agenix secrets are never at risk here: they live in `/run/agenix` at activation time, not in the store. What *is* in a NixOS toplevel is `users-groups.json` containing `hashedPassword`.

### Determinate Nix

`flake.nix` tracks the `determinate/3` semver range, so `just update` always moves to the latest 3.x release. How that release reaches each host differs by platform:

**macOS** — the nix-darwin module sets `nix.enable = lib.mkForce false`; it never builds Nix. The running Nix is the installer-managed binary, upgraded imperatively with `sudo determinate-nixd upgrade` (prebuilt download, no compile). The flake input does not control the Mac's Nix version.

**NixOS** — the module sets `nix.package` to the `nix-src` flake output (`modules/nixos.nix:31`). That store path is on neither `cache.nixos.org` nor the public `https://install.determinate.systems` cache (verified with `nix path-info --store`, for both the current and the previously-shipping version — that cache serves installer artifacts, not nix-src flake outputs). The only upstream source is FlakeHub Cache (`https://cache.flakehub.com`), which is **paid and needs imperative per-machine auth** (`determinate-nixd login`; hosts are `logged-out`, and there is no declarative equivalent).

So on NixOS Nix would otherwise be recompiled per host per bump. The workaround is **`just cache-determinate`**: build it once on nixos-server-01 and push the ~130 MiB closure to `birkhoff.cachix.org`, which every host already trusts. `nixos-desktop-01` is the only NixOS host left in this repo, but it is x86_64-linux like the builder, so that one build covers it.

**`deploy-desktop` runs `just cache-determinate` first**, as a just prerequisite, so the normal workflow (`just update` → `just deploy-desktop`) never recompiles Nix. The `switch-nixos-desktop` recipe uses `--build-host nixos-server-01` and shares the same build.

The build and the push both run on nixos-server-01 — nothing is copied back to the Mac. That host is configured from `~/Documents/Infrastructure/Homelab`, which keeps its credentials as plain files rather than agenix; the token is still readable at `/run/agenix/cachix-token` because that repo's `services/cachix.nix` keeps the path alive as a tmpfiles symlink to `/etc/cachix-token`, specifically so this recipe needed no edit. The recipe reads the token into `CACHIX_AUTH_TOKEN` on the far side, so it never crosses the wire. Because the push is server-side, extending it to whole system closures is just a matter of changing what gets piped into `cachix push`.

The remote command runs `bash -eo pipefail` without `-u`: NixOS's `/etc/bashrc` is sourced for non-interactive shells and is not `set -u` clean.

Garbage collection is ours, not Determinate Nixd's. Its collector cannot delete old generations, and `nixos-desktop-01`'s disk reached 100% with it running, so each host runs a weekly `--delete-older-than` job and sets `garbageCollector.strategy = "disabled"`, as [Determinate advises](https://docs.determinate.systems/determinate-nix/best-practices/) when running your own. On macOS that job is a `launchd.daemons` entry, because `nix.gc.automatic` requires `nix.enable`. There is no urgent mode with its collector off.

Do not add `inputs.determinate.inputs.nixpkgs.follows` — upstream warns it causes cache misses for FlakeHub Cache artifacts.

Note that on NixOS the Determinate module retargets the generated `nix.conf` to `/etc/nix/nix.custom.conf` (`modules/nixos.nix:77`), which determinate-nixd includes — so `nix.settings` from `shared-nix-settings.nix` does still take effect.

## Common Development Commands

### Building and Switching Configurations

Using `just` (preferred):
```bash
just switch                 # Build and switch to new configuration (alias: just s)
just switch-nixos-desktop   # Switch nixos-desktop-01 remotely via nh os switch
just deploy-desktop         # Deploy nixos-desktop-01 via deploy-rs (runs cache-determinate first)
just build-desktop-image    # Build Proxmox VMA for nixos-desktop-01 (runs on nixos-server-01)
just update                 # Update all flake inputs and commit lock file (alias: just u)
just update-input <name>    # Update specific flake input (alias: just ui)
just format                 # Format the whole repo via nixfmt-tree (nix fmt)
just lint                   # Run the pre-commit hooks (nixfmt, deadnix, statix) on every file
just optimize               # Clean old generations and optimize store (alias: just o)
just repair                 # Verify and repair Nix store
just cache-darwin           # Push darwin build artifacts to cachix
just cache-attic            # Push the full darwin closure to Attic, for bootstrapping a new Mac
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
nix eval ".#nixosConfigurations.nixos-desktop-01.config.system.name"
```

> **Note:** `nix build "."` uses the git index (staged files only). If you have unstaged modifications, use `nix build "path:.#..."` to include working tree changes.

After switching, verify services are running correctly and check for any activation errors.

### Provisioning

There are no throwaway VM hosts here. `nixos-server-01` is provisioned from
`~/Documents/Infrastructure/Homelab` (see its
`docs/deployment-instructions-nixos-server-01.md`). Homelab and Proxy carry their
own `nixos-anywhere` tooling.

The OrbStack *Mac app* is unrelated and managed here: the cask in
`hosts/AlexMBP/packages/homebrew.nix` and its shell init in
`home/modules/zsh.nix`.

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

### Adding Agent Skills

Skills are managed by [agent-skills-nix](https://github.com/Kyure-A/agent-skills-nix) in `home/modules/agent-skills.nix`, for every host. Do not use `npx skills add`, even when the `find-skills` skill suggests it; it writes untracked copies into the same directories.

1. **Upstream skills**: add a `flake = false` input to `flake.nix`, declare it under `sources`, and select it with `skills.enableAll` or `skills.enable`. `just update` moves them with every other input.
2. **Your own skills**: add a source with `path = ./skills`, then keep them in `home/modules/skills/<name>/SKILL.md`.
3. **Suites that need their repo root** (commands, agents, hooks, shared files): add a `flake = false` input and link it with `home.file.".claude/skills/<name>".source`, as `academic-research-skills` does. agent-skills-nix copies only the skill directory. Avoid `programs.claude-code.plugins` for a plugin whose manifest declares component paths (`skills`, `commands`, `monitors` and so on) or that ships a hooks module: it wraps the plugin in per-entry symlinks, and Claude Code refuses those paths with "Path escapes plugin directory". Run `claude plugin list` to see this, since a normal session stays silent about it. Tracked in [home-manager#9906](https://github.com/nix-community/home-manager/issues/9906).

The targets deliberately use the `link` structure. The tree structures run `rsync --delete` on the destination, which would remove two things that live alongside the managed skills: Rex's stub in `~/.claude/skills/rex` and `~/.agents/skills/rex` (owned by `rex skill setup`), and home-manager's plugins in `~/.claude/skills`, including `claude-code-home-manager`, which carries the MCP servers.

Plugin skills (Figma, Vercel and so on) are outside this: they stay under `claude plugin`.

Adding or removing a `transform` or `packages` on an installed skill changes it between a symlink and a real directory, and activation then fails with `ln: ... Permission denied`, because home-manager tries to write through the old read-only link. Delete `~/.claude/skills/<name>` and `~/.agents/skills/<name>` and run `just switch` again.

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

   ```

   For Proxmox VM image builds (like `nixos-desktop-01`), the host uses `proxmox-image.nix` and a VMA is built via:
   ```nix
   packages.x86_64-linux.<hostname>-image = self.nixosConfigurations.<hostname>.config.system.build.VMA;
   ```
   Use `just build-desktop-image` as a template for the remote-build workflow.

## Important Implementation Details

### Justfile Architecture

Every recipe lives in the root `justfile`. To split out specialized commands, create a `.just` file under a new `justfiles/` directory and add `import 'justfiles/<name>.just'` to the root `justfile`.

**Justfile groups** organize commands:
- `darwin`: macOS-specific commands (switch)
- `homelab`: Homelab commands (switch-nixos-desktop, deploy-desktop, build-desktop-image)
- `flake`: Flake management (update, update-input)
- `nix-misc`: Nix store maintenance (optimize, repair)
- `cache`: Cachix operations (cache-darwin)
- `code-quality`: Code formatting and linting (format, lint)
- `secrets`: Secret management (edit-secret)

### Secrets Management

Secrets are managed with **agenix** (age-encrypted secrets checked into git).

- **`secrets/agenix-rules.nix`**: Declares which public keys can decrypt each `.age` file. The `ale` key is the SSH ed25519 public key corresponding to the 1Password identity.
- **`secrets/*.age`**: Encrypted secret files (ssh-config, tailscale authkey, mcp-env).
- **`hosts/AlexMBP/age-identity.txt`**: The `AGE-PLUGIN-1P` identity used to decrypt secrets on AlexMBP. This is host-specific and lives alongside the agenix config.
- **`hosts/AlexMBP/ssh-config.nix`**: Configures the agenix home-manager module — sets `age.package`, `age.identityPaths`, declares secrets, and overrides the launchd agent's `KeepAlive` (removing `Crashed = false` which would otherwise cause the agent to loop on every clean exit).
- **`packages/age-with-plugins.nix`**: Custom `age` derivation that wraps `age-plugin-1p` with a `umask 077` reset before exec. Required because the agenix mount-secrets script sets `umask u=r,g=,o=` in a subshell, which would otherwise cause `op` to create its session file as `0400` (breaking subsequent invocations).

To edit a secret (uses 1Password for the decryption identity):
```bash
just edit-secret <file.age>   # runs from secrets/ directory
```

A private `dotfiles.secret` flake input is also referenced for sensitive files requiring SSH credentials to access.

### Homelab-Specific Architecture

`nixos-server-01` is configured from `~/Documents/Infrastructure/Homelab`, not
here. What remains in this repo is the *dependency* on it, in two places that
intentionally still name the host:

- **`hosts/nixos-desktop-01/remote-builder.nix`** — the desktop runs with
  `max-jobs = 0` and forwards every derivation to nixos-server-01 over ssh-ng,
  authenticating with its own pre-seeded SSH host key (authorized for root on
  the server by the Homelab config) and pinning the server's `publicHostKey`.
  If that host is down, builds on the desktop fail outright rather than falling
  back to local compilation.
- **`just cache-determinate` / `just build-desktop-image`** — both build on
  nixos-server-01 over SSH. The former reads the cachix token from
  `/run/agenix/cachix-token`, a path the Homelab config deliberately preserves
  as a tmpfiles symlink so these recipes did not need changing.

Secrets here are encrypted to the `ale` key (1Password) and, for
`tailscale-authkey.age`, to `nixos-desktop-01`'s SSH host key.

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
- `functions.zsh`: Custom functions (impaste, timer, aic, gg, s, nr, ns)
- `keys.zsh`: Custom Zsh keybindings (Ctrl+U, Alt+Q, Alt+Shift+S, etc.)
- `fzf.zsh`: fzf-tab configuration with smart previews
- `proxy.zsh`: Auto-propagated proxy settings from macOS system preferences
- `completions.zsh`: Custom completions
- `options.zsh`: Zsh options
- `colors.zsh`: Color definitions
- `op.zsh`: 1Password shell integration
- `utilities/`: Standalone scripts (shrinkvid, burnsrt, favicon, ...), installed to `~/.local/bin` by `home/modules/scripts.nix`

These are symlinked to `~/.shell/` and sourced in `home/modules/zsh.nix`.

### Development Environments

Prefer per-project environments (`nix-shell -p <packages>`, a `shell.nix`, or a flake devShell through `direnv`) over adding development tools to the global package lists.

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
