{ ... }:

{
  nix.settings = {
    # Additive caches — use extra-* to preserve defaults (including Determinate Nix caches)
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://birkhoff.cachix.org"
      "https://helix.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "birkhoff.cachix.org-1:m7WmdU7PKc6fsKedC278lhLtiqjz6ZUJ6v2nkVGyJjQ="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];

    # Trusted users can use extra-substituters from flakes without warnings
    trusted-users = [
      "@admin"
      "@wheel"
      "root"
    ];

    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Recommended when using `direnv` etc.
    keep-derivations = true;
    keep-outputs = true;
  };
}
