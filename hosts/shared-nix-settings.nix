_:

let
  caches = import ../lib/caches.nix;
in
{
  nix.settings = {
    # Additive caches — use extra-* to preserve defaults (including Determinate Nix caches)
    extra-substituters = caches.substituters;
    extra-trusted-public-keys = caches.trusted-public-keys;

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
