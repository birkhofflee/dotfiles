{
  pkgs,
  lib,
  config,
  ...
}:
let
  defaultModel = "openrouter/google/gemini-3.5-flash";
in
{
  home.packages = [
    pkgs.glow # shell/llm.zsh renders its output with this
    (pkgs.llm.withPlugins (
      {
        llm-anthropic = true;
        llm-gemini = true;
        llm-openrouter = true;
        llm-gguf = true;
        llm-jq = true;
        socksio = true;
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        llm-mlx = true;
      }
    ))
  ];

  home.sessionVariables = {
    LLM_USER_PATH = "${config.xdg.configHome}/llm";
    LLM_MODEL = defaultModel;
  };

  # disable logging
  xdg.configFile."llm/logs-off".text = "";

  # default model for llm CLI
  xdg.configFile."llm/default_model.txt".text = defaultModel;

  programs.zsh.shellAliases.chat = "_llm chat";

  programs.zsh.initContent = ''
    source "${config.home.homeDirectory}/.shell/llm.zsh"
  '';

  # convert image to markdown
  xdg.configFile."llm/templates/md.yaml".source = ./llm/templates/md.yaml;
}
