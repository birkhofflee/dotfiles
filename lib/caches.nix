# Binary caches added on top of cache.nixos.org, for every host's Nix daemon.
# nixConfig in flake.nix has to be a literal, so keep that list in sync by hand.
{
  substituters = [
    "https://nix-community.cachix.org"
    "https://birkhoff.cachix.org"
    "https://helix.cachix.org"
    "https://claude-code.cachix.org"
  ];

  trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "birkhoff.cachix.org-1:m7WmdU7PKc6fsKedC278lhLtiqjz6ZUJ6v2nkVGyJjQ="
    "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
  ];
}
