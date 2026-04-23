#!/usr/bin/env bash
set -euo pipefail

DISK="/dev/nvme0n1"
ROOT_LABEL="nixos"
SWAP_LABEL="swap"
BOOT_LABEL="boot"

echo "[INFO] Starting disk setup for ${DISK}"
echo "[WARN] This will irreversibly wipe and repartition ${DISK}. Proceed?"
read -n 1 -s -r

# 1) Ensure nothing from this disk is mounted or used
echo "[STEP] Disabling all swap (if any)"
swapoff -a || true

echo "[STEP] Unmounting previous mounts under /mnt (if any)"
umount -R /mnt || true

echo "[STEP] Unmounting any mounted partitions of ${DISK}"
for p in "${DISK}"p*; do
  if mount | grep -q "^${p} "; then
    echo "  - Unmounting ${p}"
    umount -f "${p}" || true
  fi
done

# 2) Wipe partition table and any leftover signatures
echo "[STEP] Zapping GPT and wiping signatures on ${DISK}"
sgdisk --zap-all "${DISK}" || true

echo "[STEP] Wiping the first 8MiB of ${DISK} to clear signatures"
dd if=/dev/zero of="${DISK}" bs=1M count=8 conv=fsync || true

echo "[STEP] Wiping ~8MiB at the end of ${DISK} to clear backup GPT"
BLOCKS=$(blockdev --getsz "${DISK}")
dd if=/dev/zero of="${DISK}" bs=512 seek=$((BLOCKS - (16 * 1024))) count=$((16 * 1024)) conv=fsync || true

# 3) Create GPT and partitions with parted non-interactively
echo "[STEP] Creating GPT label"
parted "${DISK}" -- mklabel gpt

echo "[STEP] Creating root partition: 512MiB -> -8GiB"
parted "${DISK}" -- mkpart primary 512MB -8GB

echo "[STEP] Creating swap partition: -8GiB -> 100%"
parted "${DISK}" -- mkpart primary linux-swap -8GB 100%

echo "[STEP] Creating EFI System Partition (ESP): 1MiB -> 512MiB"
parted "${DISK}" -- mkpart ESP fat32 1MB 512MB

echo "[STEP] Setting ESP flag on partition 3"
parted "${DISK}" -- set 3 esp on

echo "[STEP] Informing kernel of partition table changes"
partprobe "${DISK}"
sleep 1

# 4) Create filesystems (force where safe)
echo "[STEP] Formatting root partition (${DISK}p1) as ext4 with label '${ROOT_LABEL}'"
mkfs.ext4 -F -L "${ROOT_LABEL}" "${DISK}p1"

echo "[STEP] Initializing swap on (${DISK}p2) with label '${SWAP_LABEL}'"
mkswap -f -L "${SWAP_LABEL}" "${DISK}p2"

echo "[STEP] Formatting ESP (${DISK}p3) as FAT32 with label '${BOOT_LABEL}'"
mkfs.fat -F 32 -n "${BOOT_LABEL}" "${DISK}p3"

# 5) Mount and generate NixOS config
echo "[STEP] Mounting root filesystem by label (${ROOT_LABEL}) at /mnt"
mount "/dev/disk/by-label/${ROOT_LABEL}" /mnt

echo "[STEP] Creating and mounting /mnt/boot from ESP label (${BOOT_LABEL})"
mkdir -p /mnt/boot
mount "/dev/disk/by-label/${BOOT_LABEL}" /mnt/boot

echo "[STEP] Enabling swap by label (${SWAP_LABEL})"
swapon "/dev/disk/by-label/${SWAP_LABEL}"

echo "[STEP] Generating NixOS hardware configuration"
nixos-generate-config --root /mnt

# 6) Edit configuration.nix to include your settings
CFG="/mnt/etc/nixos/configuration.nix"
echo "[STEP] Injecting settings into ${CFG}"
awk '
  { print }
  /system\.stateVersion = .*/ {
    print "  nix.package = pkgs.nixVersions.latest;";
    print "  nix.extraOptions = \"experimental-features = nix-command flakes\";";
    print "  nix.settings.substituters = [\"https://birkhoff.cachix.org\"];";
    print "  nix.settings.trusted-public-keys = [\"birkhoff.cachix.org-1:m7WmdU7PKc6fsKedC278lhLtiqjz6ZUJ6v2nkVGyJjQ=\"];";
    print "  environment.systemPackages = [ pkgs.git ];";
    print "  services.openssh.enable = true;";
    print "  services.openssh.knownHosts = { github = { hostNames = [\"github.com\"]; publicKey = \"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl\"; }; };";
    print "  services.openssh.settings.PasswordAuthentication = true;";
    print "  services.openssh.settings.PermitRootLogin = \"yes\";";
    print "  users.users.root.openssh.authorizedKeys.keys = [\"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM\"];";
    print "  users.users.root.initialPassword = \"root\";";
  }
' "$CFG" > "${CFG}.tmp" && mv "${CFG}.tmp" "$CFG"

# 7) Install
echo "[STEP] Running nixos-install (no root passwd prompt)"
nixos-install --no-root-passwd

echo "[INFO] Installation completed successfully. Rebooting..."
reboot
