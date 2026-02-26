{ pkgs, inputs, config, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    package = inputs.helix.packages.${pkgs.system}.default;

    languages = {
      language = [{
        name = "markdown";
        formatter = {
          command = "${pkgs.dprint}/bin/dprint";
          args = ["fmt" "--config" "${config.xdg.configHome}/dprint/dprint.jsonc" "--stdin" "md"];
        };
      }];
    };

    settings = {
      theme = "snazzy";

      editor = {
        mouse = false;
        cursorline = true;
        cursor-shape.insert = "bar";
        line-number = "relative";
        color-modes = true; # Make the mode indicator colored
        # Show currently open buffers, only when more than one exists.
        bufferline = "multiple";
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "read-only-indicator"
            "file-modification-indicator"
          ];
          right = [
            "version-control"
            "diagnostics"
            "selections"
            "register"
            "position"
            "position-percentage"
            "file-encoding"
          ];
        };
        # Recommended default diagnostics settings
        # @see https://docs.helix-editor.com/editor.html#editorinline-diagnostics-section
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "warning"; # show warnings and errors on the cursorline inline
        };

        # Show hidden files in File Picker
        file-picker.hidden = false;

        auto-save = {
          focus-lost = true;
        };
        insert-final-newline = true;
        trim-trailing-whitespace = true;
        indent-guides = {
          character = "┊";
          skip-levels = 1;
        };
        soft-wrap = {
          enable = true;
        };
      };

      # This include recommended Smart Tab keybinds
      # @ see https://docs.helix-editor.com/editor.html#editorsmart-tab-section
      keys.normal = {
        "A-w" = ":buffer-close";
        "tab" = "move_parent_node_end";
        "S-tab" = "move_parent_node_start";
        "Cmd-s" = ":write";
        "Cmd-f" = "page_down";
        "Cmd-b" = "page_up";
        "C-j" = "half_page_down";
        "C-k" = "half_page_up";
        "X" = "select_line_above"; # Shift-x undos the last X

        # Move line up/down
        "A-down" = [
          "extend_to_line_bounds"
          "delete_selection"
          "paste_after"
        ];
        "A-up" = [
          "extend_to_line_bounds"
          "delete_selection"
          "move_line_up"
          "paste_before"
        ];

        "space" = {
          # Print the current line's git blame information to the statusline.
          "B" = ":echo %sh{git blame -L %{cursor_line},+1 %{buffer_name}}";
          "A-d" = ":pipe awk '!s[$0]++'";
        };

        # yazi integration
        # https://github.com/sxyazi/yazi/pull/2461
        "C-y" = [
          ":sh rm -f /tmp/helix-yazi-tmpfile"
          ":insert-output yazi \"%{buffer_name}\" --chooser-file=/tmp/helix-yazi-tmpfile"
          ":insert-output echo \"\x1b[?1049h\x1b[?2004h\" > /dev/tty"
          ":open %sh{cat /tmp/helix-yazi-tmpfile}"
          ":redraw"
          ":set mouse false"
          ":set mouse true"
        ];

        # lazygit integration
        "C-d" = [
          ":sh rm -f /tmp/helix-yazi-tmpfile"
          ":new"
          ":insert-output lazygit"
          ":set mouse false"
          ":set mouse true"
          ":buffer-close!"
          ":redraw"
          ":reload-all"
        ];
      };

      keys.insert = {
        "S-tab" = "move_parent_node_start";
        "Cmd-s" = ":write";
        "Cmd-b" = "page_up";
        "Cmd-f" = "page_down";
      };

      keys.select = {
        "tab" = "extend_parent_node_end";
        "S-tab" = "extend_parent_node_start";
        "Cmd-s" = ":write";
        "Cmd-b" = "page_up";
        "Cmd-f" = "page_down";
        "X" = "select_line_above"; # Shift-x undos the last X
      };
    };
  };
}
