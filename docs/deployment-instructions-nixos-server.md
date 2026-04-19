# Deploying nixos-server-01 to a fresh Proxmox VM

## Prerequisites

- PVE host reachable via SSH as `homelab-nuc`
- New VM created in PVE with: UEFI/OVMF bios, VirtIO SCSI disk, [NixOS minimal ISO](https://channels.nixos.org/nixos-25.11/latest-nixos-minimal-x86_64-linux.iso) attached
- VM booted into the NixOS installer (set password to `nixos` using `passwd`)

## 1. Find the VM's IP

```bash
# Get the VM's MAC address from PVE config
ssh homelab-nuc "qm config <vmid>"

# Then find its IP via ARP
ssh homelab-nuc "ip neigh show | grep <vm-mac>"
```

## 2. Copy SSH key to the installer

```bash
# Copy PVE root's key to the installer via sshpass
ssh homelab-nuc "sshpass -p nixos ssh-copy-id -o StrictHostKeyChecking=no -o PubkeyAuthentication=no nixos@<VM_IP>"

# Add your Mac's key to root on the installer
MY_KEY=$(cat ~/.ssh/id_ed25519.pub)
ssh homelab-nuc "ssh nixos@<VM_IP> 'sudo mkdir -p /root/.ssh && echo \"$MY_KEY\" | sudo tee /root/.ssh/authorized_keys && sudo chmod 700 /root/.ssh && sudo chmod 600 /root/.ssh/authorized_keys'"

# Verify root access works
ssh -o ProxyJump=homelab-nuc root@<VM_IP> "whoami"
```

## 3. Generate new SSH host key pair

```bash
mkdir -p /tmp/nixos-server-01-host-keys/etc/ssh
ssh-keygen -t ed25519 -N "" -f /tmp/nixos-server-01-host-keys/etc/ssh/ssh_host_ed25519_key -C ""
cat /tmp/nixos-server-01-host-keys/etc/ssh/ssh_host_ed25519_key.pub
```

## 4. Update secrets with the new host key

Edit `secrets/secrets.nix` and replace the `nixos-server-01` public key with the one generated in step 3:

```nix
nixos-server-01 = "ssh-ed25519 AAAA...";
```

Re-encrypt all secrets:

```bash
op read 'op://Personal/id_ed25519/private key?ssh-format=openssh' > /tmp/age-identity.key && chmod 600 /tmp/age-identity.key
cd secrets && agenix -r --identity /tmp/age-identity.key
rm /tmp/age-identity.key
```

Stage the changes so nix can find them:

```bash
cd /path/to/dotfiles
git add hosts/nixos-server-01/ secrets/
```

## 5. Update Tailscale auth key

```bash
just edit-secret tailscale-authkey.age
```

## 6. Run nixos-anywhere

> **Note:** the binary cache didn't seem to be actually used
> when building - additional testing needed.

```bash
chmod 600 /tmp/nixos-server-01-host-keys/etc/ssh/ssh_host_ed25519_key

nix run github:nix-community/nixos-anywhere -- \
  --flake .#nixos-server-01 \
  --target-host root@<VM_IP> \
  --ssh-option "ProxyJump=homelab-nuc" \
  --build-on remote \
  --extra-files /tmp/nixos-server-01-host-keys \
  --option extra-substituters "https://nix-community.cachix.org https://helix.cachix.org https://birkhoff.cachix.org https://install.determinate.systems" \
  --option extra-trusted-public-keys "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs= birkhoff.cachix.org-1:m7WmdU7PKc6fsKedC278lhLtiqjz6ZUJ6v2nkVGyJjQ= cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
```

Wait for `### Done! ###`. The VM reboots automatically into the installed system.

## 7. Configure VM via PVE CLI

Run on `homelab-nuc`. All commands use `qm set <vmid>` (see `man qm` or [PVE docs](https://pve.proxmox.com/pve-docs/chapter-qm.html)).

```bash
ssh homelab-nuc

# Set CPU type to host — exposes all host CPU features (AVX2, AVX-512, SHA-NI,
# etc.) for better performance. Safe on a single-node cluster where live
# migration is impossible regardless. Do NOT use on multi-node clusters with
# mixed CPU generations (use x86-64-v2-AES or lowest common model instead).
qm set <vmid> --cpu host

# Enable start at boot (metadata only, takes effect immediately)
qm set <vmid> --onboot 1

# Enable QEMU Guest Agent integration (PVE-side flag; NixOS already has
# services.qemuGuest.enable = true which runs the agent daemon in the guest)
qm set <vmid> --agent enabled=1

# Add VirtIO RNG — feeds host entropy into the guest kernel, useful for
# Tailscale/TLS daemons that draw on /dev/random at startup.
qm set <vmid> --rng0 source=/dev/urandom

# Enable TRIM/discard on the disk so freed guest blocks are returned to the
# thin-provisioned LVM pool. Pairs with services.fstrim in the NixOS config.

# Get the full current disk string first:
qm config <vmid> | grep ^scsi0
# Then set with discard=on appended, e.g.:
qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-1,iothread=1,discard=on,size=32G
```

Afterwards do a full shutdown and start of the VM, not just a reboot.

