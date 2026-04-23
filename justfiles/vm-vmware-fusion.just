NIXADDR := env_var_or_default("NIXADDR", "unset")
NIXPORT := env_var_or_default("NIXPORT", "22")
NIXUSER := env_var_or_default("NIXUSER", "ale")

# Partition, format, generate config, enable SSH, install, reboot. Run on a fresh NixOS ISO with root password set to 'root'
[group('vmware')]
vm-bootstrap0 ip:
  rsync -av -e 'ssh {{SSH_OPTIONS}} -p{{NIXPORT}}' "./scripts/vm-installer.sh" "root@{{ip}}:/installer.sh"
  @- NIXADDR={{ip}} NIXUSER=root just _vm-ssh "bash /installer.sh"

# Finalize a freshly installed VM (copy, switch, secrets, reboot)
[group('vmware')]
vm-bootstrap ip:
  NIXADDR={{ip}} just _vm-add-root-sshkey
  NIXADDR={{ip}} just vm-sync
  NIXADDR={{ip}} just vm-switch
  NIXADDR={{ip}} just _vm-remove-root-sshkey

# Launch an interactive SSH session
[group('vmware')]
vm-ssh user='ale':
  @- NIXUSER={{user}} just _vm-ssh

# rsync repository to /nix-config on the VM
[group('vmware')]
vm-sync:
  rsync -av -e 'ssh {{SSH_OPTIONS}} -p{{NIXPORT}}' \
    --exclude='.git/' \
    --rsync-path="sudo rsync" \
    "{{FLAKES_PATH}}/" "root@{{NIXADDR}}:/nix-config"

# nixos-rebuild switch on the VM
[group('vmware')]
vm-switch:
  @NIXUSER=root just _vm-ssh "ulimit -n 65536 && NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nh os switch --bypass-root-check --hostname nixos-vm-aarch64 /nix-config -- --accept-flake-config "

_vm-ssh command='':
  ssh {{SSH_OPTIONS}} -p{{NIXPORT}} {{NIXUSER}}@{{NIXADDR}} -- "{{command}}"

_vm-add-root-sshkey:
  @op read "op://Personal/id_ed25519/id_ed25519" | NIXUSER=root just _vm-ssh 'umask 077 && mkdir -p /root/.ssh && cat > /root/.ssh/id_ed25519 && chmod 600 /root/.ssh/id_ed25519'

_vm-remove-root-sshkey:
  @NIXUSER=root just _vm-ssh 'rm -f /root/.ssh/id_ed25519'
