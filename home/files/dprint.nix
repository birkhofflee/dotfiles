{
  xdg.configFile."dprint/dprint.jsonc" = {
    text = ''
      {
        "markdown": {
          "lineWidth": 80,
        },
        "excludes": [],
        "plugins": [
          "https://plugins.dprint.dev/markdown-0.20.0.wasm",
          "https://plugins.dprint.dev/typescript-0.95.13.wasm",
          "https://plugins.dprint.dev/json-0.21.1.wasm",
          "https://plugins.dprint.dev/toml-0.7.0.wasm",
          "https://plugins.dprint.dev/dockerfile-0.3.3.wasm",
          "https://plugins.dprint.dev/ruff-0.6.13.wasm"
        ]
      }
    '';
  };
}
