{
  # disable logging
  xdg.configFile."llm/logs-off" = {
    text = "";
  };

  # convert image to markdown
  xdg.configFile."llm/templates/md.yaml".source = ./llm/templates/md.yaml;
}
