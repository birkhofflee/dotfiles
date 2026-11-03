{ config, lib, pkgs, ... }:

{
  options.dotfiles.neovim.mutableConfig = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Link ~/.config/nvim to the repo checkout at ~/.config/dotfiles, so
      lazy.nvim can write lazy-lock.json / lazyvim.json back into git. Disable
      on hosts applied straight from a `github:` flake ref with no checkout
      (e.g. WSL), where that symlink would dangle; the config is then a
      read-only store copy and lazy.lua keeps the lockfile in stdpath("data").
    '';
  };

  config = {
    home.packages = [
      # Plain package rather than programs.neovim: that module writes its own
      # ~/.config/nvim/init.lua, which would collide with the LazyVim symlink below
      (pkgs.neovim.override {
        withPython3 = false;
        withRuby = false;
      })
      pkgs.tree-sitter # Needed by LazyVim's nvim-treesitter to build parsers

      # Tools LazyVim's lang.nix extra shells out to (nil_ls is already installed)
      pkgs.statix # nvim-lint linter
      pkgs.nixfmt # conform.nvim formatter
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # LazyVim config
    xdg.configFile."nvim".source =
      if config.dotfiles.neovim.mutableConfig then
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/home/modules/lazyvim"
      else
        ./lazyvim;
  };
}
