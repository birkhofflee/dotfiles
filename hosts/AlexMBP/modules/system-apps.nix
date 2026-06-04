{ ... }:

{
  system.defaults.CustomUserPreferences = {
    "com.apple.assistant.support" = {
      "Dictation Enabled" = 1;
    };

    "com.apple.CrashReporter" = {
      DialogType = "developer";
      UseUNC = true;
    };

    "com.apple.Music" = {
      AppleLanguages = [
        "zh-Hant-US"
      ];
      audioPassthroughSetting = 1;
      dontAskForPlaylistItemRemoval = 1;
      downloadDolbyAtmos = 1;
      losslessEnabled = 1;
      preferredDownloadAudioQuality = 20;
      preferredStreamPlaybackAudioQuality = 15;
    };

    "com.apple.terminal" = {
      # Only use UTF-8
      StringEncodings = (4);
    };

    "com.apple.TimeMachine" = {
      # Prevent Time Machine from prompting to use new hard drives as backup volume
      DoNotOfferNewDisksForBackup = true;
    };

    "com.apple.TextEdit" = {
      # Use plain text mode for new documents
      RichText = 0;

      # Open and save files as UTF-8
      PlainTextEncoding = 4;
      PlainTextEncodingForWrite = 4;
    };

    "com.apple.DiskUtility" = {
      # Enable the debug menu
      DUDebugMenuEnabled = true;
      "advanced-image-options" = true;
    };

    "com.apple.QuickTimePlayerX" = {
      # Auto-play videos
      MGPlayMovieOnOpen = true;
    };

    "com.apple.appstore" = {
      # Enable the WebKit Developer Tools in the Mac App Store
      WebKitDeveloperExtras = true;

      # Enable Debug Menu in the Mac App Store
      ShowDebugMenu = true;
    };

    "com.apple.SoftwareUpdate" = {
      # Enable the automatic update check
      AutomaticCheckEnabled = true;

      # Download newly available updates in background
      AutomaticDownload = 1;

      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };

    "com.apple.commerce" = {
      # Turn on app auto-update
      AutoUpdate = true;
    };

    "com.apple.ImageCapture" = {
      # Prevent Photos from opening automatically when devices are plugged in
      disableHotPlug = true;
    };

    "com.apple.ActivityMonitor" = {
      # Show the main window when launching
      OpenMainWindow = true;

      # Visualize CPU usage in the Dock icon
      IconType = 5;

      # Show all processes
      ShowCategory = 0;

      # Sort results by CPU usage
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };
  };
}
