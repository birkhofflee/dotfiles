{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    nodejs
  ];

  home.file.".npmrc".text = ''
    # Prevent supply chain attacks by ignoring packages published in the last 7 days
    min-release-age=7
  '';

  home.sessionVariables = {
    NODE_REPL_HISTORY = "${config.xdg.dataHome}/node_repl_history";
    NODE_REPL_MODE = "sloppy";
  };
}
