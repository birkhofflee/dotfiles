{ lib, ... }:
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
      minimum-contrast = 1.1;

      # =========================
      # FONT SETTINGS
      # =========================
      font-family = [
        "Berkeley Mono Variable" # https://luke.hsiao.dev/blog/berkeley-mono-ghostty
        # "CommitMono Nerd Font"
        # "SF Mono"
        # "IBM Plex Mono"
        # "JuliaMono" # For the glyph. https://juliamono.netlify.app/
        "Noto Sans" # as fallback for CJK characters
      ];
      # Font width (60 to 100)
      #  60 = UltraCondensed
      #  70 = ExtraCondensed
      #  80 = Condensed
      #  90 = SemiCondensed
      # 100 = Normal
      #
      # Font weight (100 to 900)
      # 100 = Thin
      # 200 = ExtraLight
      # 300 = Light
      # 350 = SemiLight
      # 400 = Regular
      # 500 = Medium
      # 600 = SemiBold
      # 700 = Bold
      # 800 = ExtraBold
      # 900 = Black
      font-variation = [
        "wdth=100"
        "wght=450"
      ];
      font-size = 15;
      # bold-is-bright = true
      # font-thicken = true

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

        "super+c=copy_to_clipboard"
        "super+v=paste_from_clipboard"
        "super+s=text:\\x1b[115;9u" # KKP encoding for Cmd+S (for Helix :write)

        # Moving around terminal buffer
        "super+end=scroll_to_bottom"
        "super+home=scroll_to_top"
        "super+page_down=scroll_page_down"
        "super+page_up=scroll_page_up"

        # Resizing splits
        "super+shift+0=equalize_splits"
        "super+shift+arrow_down=resize_split:down,50"
        "super+shift+arrow_left=resize_split:left,50"
        "super+shift+arrow_right=resize_split:right,50"
        "super+shift+arrow_up=resize_split:up,50"

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

        # Undo & Redo
        "super+z=text:\\x1f"
        "super+shift+z=text:\\x18\\x1f"
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
