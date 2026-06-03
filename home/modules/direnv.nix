{
  programs.direnv = {
    enable = true;

    # Use nix-direnv to replace the built-in support
    # for Nix. This handles caching better and prevents
    # GC to erase our devshell caches.
    #
    # @see https://github.com/direnv/direnv/wiki/Nix
    nix-direnv.enable = true;
  };

  # @see https://github.com/direnv/direnv/issues/1418#issuecomment-2820125413
  xdg.configFile."direnv/direnv.toml".text = "";
}
