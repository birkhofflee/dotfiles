{ ... }:

{
  system.defaults = {
    LaunchServices = {
      # Disable quarantine for downloaded applications.
      LSQuarantine = false;
    };

    finder = {
      # Don't show hidden files
      "AppleShowAllFiles" = false;

      # Always show file extensions
      "AppleShowAllExtensions" = true;

      # Show status bar at bottom of finder windows with item/disk space stats
      "ShowStatusBar" = true;

      # Show path breadcrumbs in finder windows
      "ShowPathbar" = true;

      # Show the full POSIX filepath in the window title
      "_FXShowPosixPathInTitle" = true;

      # When performing a search, search the current folder by default
      "FXDefaultSearchScope" = "SCcf";

      # Disable the warning when changing a file extension
      "FXEnableExtensionChangeWarning" = false;

      # Use list view in all Finder windows by default
      "FXPreferredViewStyle" = "Nlsv";
    };

    CustomUserPreferences = {
      "com.apple.finder" = {
        # Use absolute dates (not relative like "yesterday")
        # RelativeDates = false;

        # Keep the desktop clean
        ShowHardDrivesOnDesktop = false;
        ShowRemovableMediaOnDesktop = false;
        ShowExternalHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;

        # New window use the $HOME path
        NewWindowTarget = "PfHm";
        NewWindowTargetPath = "file://$HOME/";

        # Allow text selection in Quick Look
        QLEnableTextSelection = true;

        # Keep folders on top when sorting by name
        "_FXSortFoldersFirst" = true;

        # Auto-adjust column widths to filenames in "Columns" view
        "_FXEnableColumnAutoSizing" = 1;

        # Open folder in new window by: ⌘ + double-click
        FinderSpawnTab = false;

        # Expand some File Info panes
        "FXInfoPanesExpanded" = {
          Comments = false;
          General = true;
          MetaData = true;
          Name = true;
          OpenWith = true;
          Preview = true;
          Privileges = true;
        };
      };

      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network volumes
        "DSDontWriteNetworkStores" = true;

        # Avoid creating .DS_Store files on USB volumes
        "DSDontWriteUSBStores" = true;
      };

      "NSGlobalDomain" = {
        # Open a folder automatically when hovering over it while dragging a file
        "com.apple.springing.enabled" = 1;

        # Seconds to wait before spring-loading activates (0.5 s feels responsive without being hair-trigger)
        "com.apple.springing.delay" = "0.5";
      };
    };
  };
}
