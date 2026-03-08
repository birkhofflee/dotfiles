{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        overrideGpg = true;

        pagers = [
          {
            pager = "delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
            colorArg = "always";
          }
        ];

        commit = {
          signOff = true;
        };
      };

      # Catppuccin Macchiato - Blue Accent
      # @see https://github.com/catppuccin/lazygit/blob/main/themes-mergable/macchiato/blue.yml
      gui = {
        mouseEvents = false;

        theme = {
          activeBorderColor = [
            "#8aadf4"
            "bold"
          ];
          inactiveBorderColor = [
            "#a5adcb"
          ];
          optionsTextColor = [
            "#8aadf4"
          ];
          selectedLineBgColor = [
            "#363a4f"
          ];
          cherryPickedCommitBgColor = [
            "#494d64"
          ];
          cherryPickedCommitFgColor = [
            "#8aadf4"
          ];
          unstagedChangesColor = [
            "#ed8796"
          ];
          defaultFgColor = [
            "#cad3f5"
          ];
          searchingActiveBorderColor = [
            "#eed49f"
          ];
        };

        authorColors = {
          "*" = "#b7bdf8";
        };
      };
    };
  };
}
