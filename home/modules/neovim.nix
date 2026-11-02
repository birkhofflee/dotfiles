{ config, pkgs, ... }:

{
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

  # LazyVim config. Out-of-store symlink so lazy.nvim can write
  # lazy-lock.json / lazyvim.json back into the repo.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/home/modules/lazyvim";
}
