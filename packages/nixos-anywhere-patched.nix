{ nixos-anywhere }:
# Patch nixos-anywhere to set up zram swap before kexec on low-memory VPS.
# https://github.com/nix-community/nixos-anywhere/issues/609
nixos-anywhere.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./patches/nixos-anywhere-zram.patch ];
})
