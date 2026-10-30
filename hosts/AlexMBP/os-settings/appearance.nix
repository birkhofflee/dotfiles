{ ... }:

{
  system.defaults = {
    NSGlobalDomain = {
      # Automatically switch between light and dark mode
      AppleInterfaceStyleSwitchesAutomatically = false;

      # Expand save panel by default
      "NSNavPanelExpandedStateForSaveMode" = true;
      "NSNavPanelExpandedStateForSaveMode2" = true;

      # Expand print panel by default
      "PMPrintingExpandedStateForPrint" = true;
      "PMPrintingExpandedStateForPrint2" = true;

      # Finder: show all filename extensions
      "AppleShowAllExtensions" = true;

      # Save to disk (not to iCloud) by default
      "NSDocumentSaveNewDocumentsToCloud" = false;
    };

    CustomUserPreferences = {
      "NSGlobalDomain" = {
        # Add a context menu item for showing the Web Inspector in web views
        "WebKitDeveloperExtras" = true;

        # Date format in Finder
        AppleICUDateFormatStrings = {
          "1" = "yyyy-MM-dd";
          "2" = "yyyy-MM-dd";
          "3" = "yyyy-MM-dd";
          "4" = "yyyy-MM-dd";
        };

        # No screen flash on alert sound (visual bell off)
        "com.apple.sound.beep.flash" = 0;
      };

      "com.apple.menuextra.clock" = {
        # Show abbreviated day of week before the time (Mon 10:30)
        ShowDayOfWeek = 1;
      };

      "com.apple.WindowManager" = {
        # No gap between windows when using window tiling
        EnableTiledWindowMargins = 0;
      };
    };
  };
}
