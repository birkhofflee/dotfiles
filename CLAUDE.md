# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a cross-platform Nix configuration repository supporting both **macOS** (via nix-darwin) and **NixOS**, using Nix flakes for reproducible system configuration. The setup uses a shared home-manager configuration that works across all systems.

**Current hosts:**
- `AlexMBP`: macOS (M1 Pro, Sequoia) - nix-darwin
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
│   │   ├── os-settings.nix
│   │   ├── age-identity.txt  # 1Password age plugin identity for decryption
│   │   ├── ssh-config.nix    # agenix HM module config + secret declarations
│   │   └── packages/
│   ├── nixos-vm-aarch64/       # VMware Fusion NixOS VM
│   │   └── default.nix   # System configuration
│   ├── nixos-orbstack/   # OrbStack NixOS VM
│   │   └── default.nix   # System configuration
│   ├── nixos-server-01/  # Proxmox VM (homelab server)
│   │   ├── default.nix
│   │   ├── disk-config.nix   # disko BTRFS layout
│   │   ├── facter.json       # nixos-facter hardware report (pre-committed)
│   │   ├── home.nix          # Custom home config (not shared home/)
│   │   └── services/         # tailscale, atuin, rybbit, caddy, cloudflared
│   ├── nixos-desktop-01/ # Proxmox VM (GUI desktop)
│   │   ├── default.nix   # Entry point: imports sub-modules + sets stateVersion
│   │   ├── hardware.nix  # Boot, proxmox VM config, zramSwap, enableHardwareAccel option
│   │   ├── networking.nix # Hostname, firewall, tailscale, openssh, SSH host key pre-seeding
│   │   ├── desktop.nix   # GNOME/GDM, dconf HiDPI, GNOME Remote Desktop service, sleep targets
│   │   ├── users.nix     # Users, fonts, system packages, timezone, sudo, i18n
│   │   └── home.nix      # Custom home config (CLI/shell tools; not the shared home/)
│   └── shared-nix-settings.nix  # Shared Nix daemon settings
├── home/                  # Shared home-manager configuration
│   ├── default.nix        # Main home config (platform-agnostic)
│   ├── programs/          # Program-specific configs (auto-imported)
│   ├── files/             # Config files (auto-imported)
│   ├── packages/          # User packages
│   └── libs/              # Helper libraries
├── packages/              # Custom Nix derivations (exposed via custom-packages overlay)
│   ├── age-with-plugins.nix           # age + age-plugin-1p wrapper with umask fix
│   └── nixos-anywhere-patched.nix     # nixos-anywhere with local patches
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
- **Overlays system**: Provides access to different package versions and custom packages
  - `pkgs-stable`, `pkgs-unstable`: Different nixpkgs versions
  - `zellij-plugins`: Custom Zellij plugins (zjstatus, zjstatus-hints, zj-quit)
  - `custom-packages`: Local derivations in `packages/` (`age-with-plugins`, `nixos-anywhere` patched)
  - `tweaks`: Temporary per-package overrides (e.g., pinned `mactop` version)
- **lib/mksystem.nix**: Helper function that simplifies creating system configurations for both Darwin and NixOS
- **devShells.default**: Available via `nix develop` - provides `just`, `nh`, `agenix`, `nixfmt-tree`, `nixos-anywhere`, `ssh-copy-id`, and sets `NH_FLAKE="."`

### Configuration Philosophy

**Separation of Concerns:**
1. **System-level** (`hosts/<hostname>/default.nix`): OS-specific configuration (nix-darwin or NixOS)
2. **User-level** (`home/default.nix`): Shared home-manager configuration, platform-agnostic

The `lib/mksystem.nix` helper abstracts away the differences between Darwin and NixOS configurations, automatically:
- Selecting the correct system function (darwinSystem vs nixosSystem)
- Applying overlays and nixpkgs configuration
- Integrating home-manager with correct modules (default: `home/`, overridable via `homeConfig` parameter)
- Integrating nix-index-database and agenix
- Passing special arguments to modules (`currentSystem`, `currentSystemName`, `currentSystemUser`, `inputs`)
- Optionally including disko and nixos-facter modules when `nixos-anywhere = true`

### Home Configuration (`home/`)

The home-manager configuration is **shared across all hosts** and platform-agnostic:
- Automatically imports all `.nix` files from `./programs/` and `./files/`
- Uses `pkgs.stdenv.isDarwin` to conditionally enable macOS-specific features
- Session PATH configuration for Rust, Go, Python (uv), and platform-specific paths
- Platform-specific activation scripts (e.g., macOS wallpaper, Library visibility)
- `home/libs/wallpaper.nix`: Helper library for downloading and setting the Raycast wallpaper (used by activation scripts)

### Host Configurations

**AlexMBP** (`hosts/AlexMBP/default.nix`):
- nix-darwin system configuration
- System packages and Homebrew integration
- macOS-specific OS settings and network configuration
- Activation scripts (Rosetta installation, Homebrew setup, locate database)

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
- Uses a custom home config at `hosts/nixos-server-01/home.nix` (not the shared `home/`)
- Services: tailscale, atuin, rybbit (analytics), caddy (reverse proxy), cloudflared (tunnel)
- Containers (Podman): rybbit-backend, rybbit-client, rybbit-postgres, rybbit-clickhouse
- Uses zramSwap for better memory management

**nixos-desktop-01** (`hosts/nixos-desktop-01/default.nix`):
- NixOS Proxmox VM with a full GUI desktop on `homelab-nuc`
- Default desktop: GNOME with GDM and GNOME Remote Desktop (RDP on port 3389)
- Hyprland specialization: selectable at boot; uses wayvnc (VNC on port 5900) for remote access
- Built as a Proxmox VMA image via `packages.x86_64-linux.nixos-desktop-01-image`; use `just build-desktop-image` (builds remotely on nixos-server-01 then rsync to PVE)
- Uses a custom home config at `hosts/nixos-desktop-01/home.nix` (CLI/shell tools; not the shared `home/`)
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

## Common Development Commands

### Building and Switching Configurations

Using `just` (preferred):
```bash
just switch                 # Build and switch to new configuration (alias: just s)
just switch-nixos-server    # Switch nixos-server-01 remotely via nh os switch
just switch-nixos-desktop   # Switch nixos-desktop-01 remotely via nh os switch
just build-desktop-image    # Build Proxmox VMA for nixos-desktop-01 (runs on nixos-server-01)
just update                 # Update all flake inputs and commit lock file (alias: just u)
just update-input <name>    # Update specific flake input (alias: just ui)
just format                 # Format all Nix files using treefmt
just optimize               # Clean old generations and optimize store (alias: just o)
just repair                 # Verify and repair Nix store
just cache-darwin           # Push darwin build artifacts to cachix
just edit-secret <file.age> # Edit an agenix secret (uses 1Password for identity)
just rekey                  # Rekey all secrets with the 1Password identity
```

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

1. Create `home/programs/<program>.nix`
2. The file is automatically imported by `home/default.nix`
3. Configure using home-manager options
4. Use `lib.mkIf pkgs.stdenv.isDarwin { ... }` for macOS-specific settings
5. Use `lib.mkIf pkgs.stdenv.isLinux { ... }` for Linux-specific settings

Example:
```nix
{ pkgs, lib, ... }:
{
  programs.myprogram = {
    enable = true;
    # Shared settings
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    # macOS-specific settings
  };
}
```

### Adding Shell Configuration

1. Create `home/files/<config>.nix` for static files
2. Create `home/files/shell/<name>.zsh` for shell scripts
3. Files are automatically imported by `home/default.nix`

### Adding Custom Packages

1. **System packages** (OS-specific): Edit `hosts/<hostname>/packages/system-packages.nix`
2. **User packages** (shared): Edit `home/packages/user-packages.nix`
3. **Homebrew apps** (macOS only): Edit `hosts/AlexMBP/packages/homebrew.nix`
4. **Custom derivations**: Create in `packages/` directory and add to overlays in `flake.nix`

### Adding a New Host

1. Create `hosts/<hostname>/default.nix`
2. Add system-specific configuration (Darwin or NixOS)
3. Use `currentSystemUser` parameter (provided by mksystem.nix) instead of hardcoding username
4. Consider importing shared configuration files:
   - `shared-nix-settings.nix`: Common Nix daemon settings
5. Add to `flake.nix`:
   ```nix
   # For macOS (darwin is auto-detected from system suffix)
   darwinConfigurations.<hostname> = mkSystem "<hostname>" {
     system = "aarch64-darwin";
     user = "ale";
   };

   # For NixOS (standard)
   nixosConfigurations.<hostname> = mkSystem "<hostname>" {
     system = "aarch64-linux";  # or "x86_64-linux"
     user = "ale";
   };

   # For NixOS with nixos-anywhere (disko + nixos-facter, custom home config)
   nixosConfigurations.<hostname> = mkSystem "<hostname>" {
     system = "x86_64-linux";
     user = "ale";
     nixos-anywhere = true;
     homeConfig = ./hosts/<hostname>/home.nix;  # optional, defaults to ./home
   };
   ```
   Note: `hosts/<hostname>/facter.json` must exist (generated by nixos-anywhere with `--generate-hardware-config nixos-facter`). `mksystem.nix` will throw an error if it's missing.

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
- `homelab`: Homelab server commands (switch-nixos-server, switch-nixos-desktop, build-desktop-image)
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
- **Custom home config**: Uses `hosts/nixos-server-01/home.nix` instead of the shared `home/`
- **Uses nixos-anywhere**: Automated remote installation with disk partitioning (disko)
- **Uses nixos-facter**: Hardware config via `hosts/nixos-server-01/facter.json` (pre-committed; do not regenerate unless hardware changes)
- **Remote deployment**: `just switch-nixos-server` uses `nh os switch` targeting `nixos-server-01` via Tailscale
- **Secrets**: agenix secrets in `secrets/` are encrypted to both the `ale` key (1Password) and the server's SSH host key. When reinstalling, the host key changes — update `secrets/secrets.nix` and rekey with `just rekey` before running nixos-anywhere

### Activation Scripts

The system uses activation scripts at multiple levels:

**System-level** (e.g., `hosts/AlexMBP/default.nix` for macOS):
- `preActivation`: Rosetta installation, Homebrew installation
- `postActivation`: Enable locate database, reveal /Volumes

**Home-level** (`home/default.nix`):
- macOS-specific (wrapped in `lib.mkIf isDarwin`):
  - `revealHomeLibraryDirectory`: Make ~/Library visible
  - `setWallpaper`: Download and set Raycast wallpaper
  - `activateUserSettings`: Restart macOS services to apply settings

Order matters: home-manager activation scripts use `lib.hm.dag.entryAfter` to ensure correct sequencing.

### Shell Configuration

The shell setup uses several specialized files (all under `home/files/shell/`):
- `functions.zsh`: Custom functions (shrinkvid, impaste, timer, aic, gg, s, nr, ns)
- `keys.zsh`: Custom Zsh keybindings (Ctrl+U, Alt+Q, Alt+Shift+S, etc.)
- `fzf.zsh`: fzf-tab configuration with smart previews
- `proxy.zsh`: Auto-propagated proxy settings from macOS system preferences
- `completions.zsh`: Custom completions
- `options.zsh`: Zsh options
- `colors.zsh`: Color definitions
- `op.zsh`: 1Password shell integration
- `utilities/`: Additional shell utility scripts

These are sourced in `home/programs/zsh.nix`.

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
