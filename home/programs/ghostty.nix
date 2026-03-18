{ lib, pkgs, ... }:
{
  # This is an attempt to fix a rare bug where after we go into a new
  # zellij session, the shell is completely broken with the message
  # `tput: No value for $TERM and no -T specified`
  #
  # This ensures that shell integration works in more scenarios (such as when you switch shells within Ghostty).
  # @see https://ghostty.org/docs/features/shell-integration#manual-shell-integration-setup
  programs.zsh.initContent = lib.mkOrder 450 ''
    if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
      source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
    fi
  '';

  programs.ghostty = {
    enable = true;
    package = null; # broken on Darwin

    # Clear the default keybinds so we have super
    # key (i.e. Command) key available to terminal
    # programs.
    clearDefaultKeybinds = true;

    # We do this ourselves because this puts the init code
    # too late (we need it to be at top of .zshrc)
    # but this fix is largely a guess.
    enableZshIntegration = false;

    # https://ghostty.org/docs/config/reference

    settings = {
      # =========================
      # THEME & COLORS
      # =========================
      #
      # Use the following to preview all available
      # builtin themes in Ghostty:
      #
      # $ ghostty +list-themes
      #
      # Some other themes to choose from:
      # theme = Horizon
      # theme = Arcoiris (with the modification of cursor-color = ffc656)
      #
      # Lighter Themes
      # theme = Sublette
      # theme = xcodedark

      # theme = "TokyoNight Storm";
      # theme = "Snazzy Soft";
      theme = "Catppuccin Macchiato";
      minimum-contrast = 1.3;

      # =========================
      # FONT SETTINGS
      # =========================
      font-family = [
        "Berkeley Mono Variable" # https://luke.hsiao.dev/blog/berkeley-mono-ghostty
        # "CommitMono Nerd Font"
        # "SF Mono"
        # "IBM Plex Mono"
        # "JuliaMono" # For the glyph. https://juliamono.netlify.app/
        # "Noto Sans"
        "Sarasa Mono TC" # as fallback for CJK characters
      ];

      # This requires the use of the variable font.
      # @see https://usgraphics.com/catalog/FX-102
      font-variation = [
        "wdth=100" # it's fixed at 100. Purchase of "Master Fonts" is required for other options
        # On macOS, font-thicken is used instead.
        (if pkgs.stdenv.isDarwin then "wght=400" else "wght=450")
      ];
      # CJK character mapping
      font-codepoint-map = [
        # CJK Symbols & Punctuation (shared: 。「」…)
        "U+3000-U+303F=Sarasa Mono TC"
        # CJK Unified Ideographs (main block — TC glyphs)
        "U+4E00-U+9FFF=Sarasa Mono TC"
        # CJK Extension A
        "U+3400-U+4DBF=Sarasa Mono TC"
        # CJK Compatibility Ideographs
        "U+F900-U+FAFF=Sarasa Mono TC"
        # Japanese: Hiragana, Katakana, Katakana Phonetic Extensions
        "U+3040-U+309F=Sarasa Mono J"
        "U+30A0-U+30FF=Sarasa Mono J"
        "U+31F0-U+31FF=Sarasa Mono J"
        # Korean: Hangul Jamo, Compatibility Jamo, Syllables
        "U+1100-U+11FF=Sarasa Mono K"
        "U+3130-U+318F=Sarasa Mono K"
        "U+AC00-U+D7AF=Sarasa Mono K"
      ];
      font-size = 15;
      bold-color = "bright";
      # Use Apple font smoothing to make texts look way clearer on macOS.
      # This also apparently make texts brighter.
      # @see https://developer.apple.com/documentation/coregraphics/cgcontext/setshouldsmoothfonts(_:)?changes=_3_11&language=objc
      # @see https://github.com/ghostty-org/ghostty/blob/d3bd224081d3c7c5ee54df6815e44f0b5d25357b/src/font/face/coretext.zig#L478-L483
      font-thicken = lib.mkIf pkgs.stdenv.isDarwin true;
      font-thicken-strength = lib.mkIf pkgs.stdenv.isDarwin 64;

      # =========================
      # COMPATIBILITY
      # @see https://ghostty.org/docs/help/terminfo
      # =========================
      # term = xterm-256color

      # =========================
      # KEYS
      # =========================
      macos-option-as-alt = true;
      keybind = [
        "super+q=quit"

        "super+shift+comma=reload_config"
        "super+shift+p=toggle_command_palette"
        "global:super+escape=toggle_quick_terminal"

        "super+n=new_window"
        "super+t=new_tab"
        "super+w=close_surface"

        "super+equal=increase_font_size:1"
        "super+-=decrease_font_size:1"

        "performable:super+c=copy_to_clipboard"
        "performable:super+v=paste_from_clipboard"
        "super+s=text:\\x1b[115;9u" # KKP encoding for Cmd+S (for Helix :write)

        # Moving around terminal buffer
        "super+end=scroll_to_bottom"
        "super+home=scroll_to_top"
        "super+page_down=scroll_page_down"
        "super+page_up=scroll_page_up"

        # Resizing splits
        "performable:super+shift+0=equalize_splits"
        "performable:super+shift+arrow_down=resize_split:down,50"
        "performable:super+shift+arrow_left=resize_split:left,50"
        "performable:super+shift+arrow_right=resize_split:right,50"
        "performable:super+shift+arrow_up=resize_split:up,50"

        # Moving around splits
        "super+shift+h=goto_split:left"
        "super+shift+j=goto_split:down"
        "super+shift+k=goto_split:up"
        "super+shift+l=goto_split:right"

        # Manipulating tabs
        "super+d=new_split:right"
        "super+shift+d=new_split:down"
        "super+shift+enter=toggle_split_zoom"

        # Moving around tabs
        "super+option+arrow_left=previous_tab"
        "super+option+arrow_right=next_tab"
        "super+1=goto_tab:1"
        "super+2=goto_tab:2"
        "super+3=goto_tab:3"
        "super+4=goto_tab:4"
        "super+5=goto_tab:5"

        # Search
        "performable:super+f=start_search"
        "performable:escape=end_search"
        "performable:super+g=navigate_search:next"
        "performable:super+shift+g=navigate_search:previous"

        # Moving around in shell
        "super+left=text:\\x01"
        "super+right=text:\\x05"

        "option+left=esc:b"
        "option+right=esc:f"

        "super+backspace=text:\\x15"

        # Undo & Redo in shell
        "super+z=text:\\x1f"
        "super+shift+z=text:\\x18\\x1f"

        # @see https://ghostty.org/docs/config/keybind/reference#undo
        # "super+z=undo"
        # "super+shift+z=redo"
      ];

      # =========================
      # INITIAL WINDOW SIZE
      # =========================
      maximize = true;
      window-height = 35;
      window-width = 98;

      # =========================
      # WINDOW PADDING
      # =========================
      # window-padding-balance = true;
      # window-padding-color = "extend";
      # window-padding-x = "2";
      window-padding-y = "2,0";

      # =========================
      # GENERAL WINDOW SETTINGS
      # =========================
      macos-titlebar-style = "transparent";
      unfocused-split-opacity = 0.65;

      # =========================
      # CURSOR & SHELL INTEGRATION
      # @see https://ghostty.org/docs/help/terminfo#ssh
      # =========================
      cursor-style = "block";
      cursor-style-blink = true;
      shell-integration = "zsh";
      shell-integration-features = "no-cursor,sudo,title";

      # =========================
      # QUICK TERMINAL
      # =========================
      quick-terminal-animation-duration = 0;

      # =========================
      # COMMAND FINISHED NOTIFICATIONS
      # =========================
      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "bell,notify";
      notify-on-command-finish-after = "30s";

      # =========================
      # WORKING DIRECTORY INHERITANCE CONTROLS
      # =========================
      window-inherit-working-directory = false;
      tab-inherit-working-directory = false;

    };
  };
}
