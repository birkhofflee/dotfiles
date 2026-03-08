{ pkgs, inputs, config, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    package = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default;

    languages = {
      language = [{
        name = "markdown";
        formatter = {
          command = "${pkgs.dprint}/bin/dprint";
          args = ["fmt" "--config" "${config.xdg.configHome}/dprint/dprint.jsonc" "--stdin" "md"];
        };
      }];
    };

    # Catppuccin Macchiato without Italics
    # @see https://github.com/catppuccin/helix/blob/main/themes/no_italics/catppuccin_macchiato.toml
    themes."catppuccin_macchiato_no_italics" = {
      "attribute" = "yellow";
      "type" = "yellow";
      "type.builtin" = "mauve";
      "type.enum.variant" = "teal";
      "constructor" = "sapphire";
      "constant" = "peach";
      "constant.character" = "teal";
      "constant.character.escape" = "pink";
      "string" = "green";
      "string.regexp" = "pink";
      "string.special" = "blue";
      "string.special.symbol" = "red";
      "comment" = { fg = "overlay2"; };
      "variable" = "text";
      "variable.parameter" = { fg = "maroon"; };
      "variable.builtin" = "red";
      "variable.other.member" = "blue";
      "label" = "sapphire";
      "punctuation" = "overlay2";
      "punctuation.special" = "sky";
      "keyword" = "mauve";
      "keyword.control.conditional" = { fg = "mauve"; };
      "operator" = "sky";
      "function" = "blue";
      "function.macro" = "rosewater";
      "tag" = "blue";
      "namespace" = { fg = "yellow"; };
      "special" = "blue";
      "markup.heading.1" = "red";
      "markup.heading.2" = "peach";
      "markup.heading.3" = "yellow";
      "markup.heading.4" = "green";
      "markup.heading.5" = "sapphire";
      "markup.heading.6" = "lavender";
      "markup.list" = "teal";
      "markup.list.unchecked" = "overlay2";
      "markup.list.checked" = "green";
      "markup.bold" = { fg = "red"; modifiers = [ "bold" ]; };
      "markup.italic" = { fg = "red"; modifiers = [ "italic" ]; };
      "markup.strikethrough" = { modifiers = [ "crossed_out" ]; };
      "markup.link.url" = { fg = "blue"; modifiers = [ "underlined" ]; };
      "markup.link.text" = "lavender";
      "markup.link.label" = "sapphire";
      "markup.raw" = "green";
      "markup.quote" = "pink";
      "diff.plus" = "green";
      "diff.minus" = "red";
      "diff.delta" = "blue";
      "ui.background" = { fg = "text"; bg = "base"; };
      "ui.linenr" = { fg = "surface1"; };
      "ui.linenr.selected" = { fg = "lavender"; };
      "ui.statusline" = { fg = "subtext1"; bg = "mantle"; };
      "ui.statusline.inactive" = { fg = "surface2"; bg = "mantle"; };
      "ui.statusline.normal" = { fg = "base"; bg = "lavender"; modifiers = [ "bold" ]; }; # customized: swapped from rosewater
      "ui.statusline.insert" = { fg = "base"; bg = "green"; modifiers = [ "bold" ]; };
      "ui.statusline.select" = { fg = "base"; bg = "rosewater"; modifiers = [ "bold" ]; }; # customized: swapped from lavender
      "ui.popup" = { fg = "text"; bg = "surface0"; };
      "ui.window" = { fg = "crust"; };
      "ui.help" = { fg = "overlay2"; bg = "surface0"; };
      "ui.bufferline" = { fg = "subtext0"; bg = "mantle"; };
      "ui.bufferline.active" = { fg = "mauve"; bg = "base"; }; # customized: removed underline
      "ui.bufferline.background" = { bg = "crust"; };
      "ui.text" = "text";
      "ui.text.focus" = { fg = "text"; bg = "surface0"; modifiers = [ "bold" ]; };
      "ui.text.inactive" = { fg = "overlay1"; };
      "ui.text.directory" = { fg = "blue"; };
      "ui.virtual" = "overlay0";
      "ui.virtual.ruler" = { bg = "surface0"; };
      "ui.virtual.indent-guide" = "surface0";
      "ui.virtual.inlay-hint" = { fg = "surface1"; bg = "mantle"; };
      "ui.virtual.jump-label" = { fg = "rosewater"; modifiers = [ "bold" ]; };
      "ui.selection" = { bg = "surface1"; };
      "ui.cursor" = { fg = "base"; bg = "secondary_cursor"; };
      "ui.cursor.primary" = { fg = "base"; bg = "rosewater"; };
      "ui.cursor.match" = { fg = "peach"; modifiers = [ "bold" ]; };
      "ui.cursor.primary.normal" = { fg = "base"; bg = "rosewater"; };
      "ui.cursor.primary.insert" = { fg = "base"; bg = "green"; };
      "ui.cursor.primary.select" = { fg = "base"; bg = "lavender"; };
      "ui.cursor.normal" = { fg = "base"; bg = "secondary_cursor_normal"; };
      "ui.cursor.insert" = { fg = "base"; bg = "secondary_cursor_insert"; };
      "ui.cursor.select" = { fg = "base"; bg = "secondary_cursor_select"; };
      "ui.cursorline.primary" = { bg = "cursorline"; };
      "ui.highlight" = { bg = "surface1"; modifiers = [ "bold" ]; };
      "ui.menu" = { fg = "overlay2"; bg = "surface0"; };
      "ui.menu.selected" = { fg = "text"; bg = "surface1"; modifiers = [ "bold" ]; };
      "diagnostic.error" = { underline = { color = "red"; style = "curl"; }; };
      "diagnostic.warning" = { underline = { color = "yellow"; style = "curl"; }; };
      "diagnostic.info" = { underline = { color = "sky"; style = "curl"; }; };
      "diagnostic.hint" = { underline = { color = "teal"; style = "curl"; }; };
      "diagnostic.unnecessary" = { modifiers = [ "dim" ]; };
      "diagnostic.deprecated" = { modifiers = [ "crossed_out" ]; };
      error = "red";
      warning = "yellow";
      info = "sky";
      hint = "teal";
      rainbow = [ "red" "peach" "yellow" "green" "sapphire" "lavender" ];
      palette = {
        rosewater = "#f4dbd6";
        flamingo = "#f0c6c6";
        pink = "#f5bde6";
        mauve = "#c6a0f6";
        red = "#ed8796";
        maroon = "#ee99a0";
        peach = "#f5a97f";
        yellow = "#eed49f";
        green = "#a6da95";
        teal = "#8bd5ca";
        sky = "#91d7e3";
        sapphire = "#7dc4e4";
        blue = "#8aadf4";
        lavender = "#b7bdf8";
        text = "#cad3f5";
        subtext1 = "#b8c0e0";
        subtext0 = "#a5adcb";
        overlay2 = "#939ab7";
        overlay1 = "#8087a2";
        overlay0 = "#6e738d";
        surface2 = "#5b6078";
        surface1 = "#494d64";
        surface0 = "#363a4f";
        base = "#24273a";
        mantle = "#1e2030";
        crust = "#181926";
        cursorline = "#303347";
        secondary_cursor = "#b6a6a7";
        secondary_cursor_select = "#8b91bf";
        secondary_cursor_normal = "#b6a6a7";
        secondary_cursor_insert = "#80a57a";
      };
    };

    settings = {
      theme = "catppuccin_macchiato_no_italics";

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
          # Shortcut to open the selected URL in default browser (macOS)
          "o" = ":sh open -u '%{selection}'";
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
