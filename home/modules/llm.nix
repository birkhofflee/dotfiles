{ pkgs, lib, ... }:
{
  home.packages = [
    (pkgs.llm.withPlugins (
      {
        llm-anthropic = true;
        llm-gemini = true;
        llm-openrouter = true;
        llm-gguf = true;
        llm-jq = true;
        llm-cmd-comp = true;
        socksio = true;
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        llm-mlx = true;
      }
    ))
  ];

  # disable logging
  xdg.configFile."llm/logs-off".text = "";

  # convert image to markdown
  xdg.configFile."llm/templates/md.yaml".source = ./llm/templates/md.yaml;
}
