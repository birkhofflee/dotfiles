{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_macchiato";
      theme_background = false;
      # btop.conf is a read-only store symlink
      save_config_on_exit = false;
      vim_keys = true;
      shown_boxes = "cpu mem net proc gpu0";
      proc_tree = true;
      proc_tree_auto_collapse = 10;
      proc_per_core = true;
      # Linux-only; ignored on macOS
      proc_filter_kernel = true;
      clock_format = "/user@/host %X";
      net_sync = false;
    };
  };
  xdg.configFile."btop/themes/catppuccin_macchiato.theme".source =
    "${pkgs.catppuccin}/btop/catppuccin_macchiato.theme";
}
