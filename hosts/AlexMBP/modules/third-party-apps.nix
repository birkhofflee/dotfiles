{ ... }:

{
  system.defaults.CustomUserPreferences = {
    "at.EternalStorms.Yoink" = {
      useHapticFeedback = 1;
      windowCorner = 0;
      fnToIgnore = 1;
      forceTouchAction = 2;
      setappDontShowAgain = 1;
      shouldHideOnLaunch = 0;

      # Hide the Yoink menu bar icon (the shelf window is the interaction point)
      showMenuBarIcon = 0;
    };

    "com.nssurge.surge-mac" = {
      AppleLanguages = [
        "zh-Hant-US"
      ];
    };

    "com.wuziqi.SenPlayer" = {
      AppleLanguages = [
        "zh-Hant-US"
      ];
    };

    "com.raycast.macos" = {
      enforcedInputSourceIDOnOpen = "com.apple.keylayout.ABC";
      raycastShouldFollowSystemAppearance = 0;
      "raycast_hyperKey_state" = {
        enabled = 1;
        includeShiftKey = 1;
        # use Right Option for hyper key
        keyCode = 230;
      };
      useHyperKeyIcon = 1;
      useSystemInternetProxySettings = 1;
    };

    "cc.ffitch.shottr" = {
      # Custom typeface in text annotations
      typeface = "Helvetica";
      # OCR (⇧⌘2)
      KeyboardShortcuts_ocr = "{\"carbonKeyCode\":19,\"carbonModifiers\":768}";
      # Fullscreen screenshot (⇧⌘3)
      KeyboardShortcuts_fullscreen = "{\"carbonKeyCode\":20,\"carbonModifiers\":768}";
      # Area screenshot (⇧⌘4)
      KeyboardShortcuts_area = "{\"carbonModifiers\":768,\"carbonKeyCode\":21}";
      "Shottr.ObjArrow: size" = 6;
      afterGrabCopy = 0;
      afterGrabSave = 0;
      afterGrabShow = 1;
      allowDeeplinks = 1;
      allowTelemetry = 0;
      altZoomDirection = 0;
      alwaysOnTop = 0;
      areaCaptureMode = "editor";
      captureCursor = "auto";
      cmdQAction = "quit";
      colorFormat = "HEX";
      contrastType = "wcag2";
      copyOnEsc = 1;

      # Filename template for saved screenshots (%Y=year, %m=month, %d=day, %t=timestamp)
      fileNameTemplate = "SCR-%Y%m%d-%t";

      # Primary language used by the OCR engine
      primaryOCRLang = "en-US";

      # Strip line breaks from OCR output (useful when copying column text)
      ocrRemoveBreaks = 1;

      # Let Shottr pick the best format per image (PNG for graphics, JPEG for photos)
      saveFormat = "Auto";

      # Use custom (in-app) notification instead of macOS banners
      notificationType = "custom";

      # Render annotation text without a visible canvas pass (sharper output)
      headlessTextRendering = 1;

      # Open the annotation editor in a large window by default
      preferLargeWindow = 1;

      # Allow the canvas to grow when annotations extend beyond the screenshot bounds
      expandableCanvas = 1;
    };

    "com.colliderli.iina" = {
      # Use hardware video decoder; falls back to software if unsupported
      hardwareDecoder = 2;

      # Automatically check for app updates via Sparkle
      SUEnableAutomaticChecks = 1;

      # Do not send anonymous hardware profile to the Sparkle update service
      SUSendProfileInfo = 0;

      # Subtitle font size in points
      subTextSize = 27;

      # When auto-loading subtitles, prefer files with this suffix (e.g. ".processed")
      subAutoLoadPriorityString = ".processed";
    };

    "com.sindresorhus.Supercharge" = {
      # Disable the ⌘Q prevention
      accidentalQuitPreventionMode = "disabled";

      # Auto-open and trash downloaded calendar event (ics) files
      autoOpenICalendarFiles = 1;
      # Remove alarms from events
      "autoOpenICalendarFiles_removeAlarms" = 1;

      # ⌥N in Finder to create new file
      finderNewFileShortcut = "optionN";
      "finderNewFileShortcut_defaultExtension" = "";
      "finderNewFileShortcut_openAfter" = 0;

      # Offer to install apps from mounted DMG files
      # Move DMG to trash after installation
      isDMGAppInstallerEnabled = 1;

      # Ensure file ext are lowercase in Downloads
      lowercaseFileExtensionsInDownloadsDirectory = 1;

      # Enable ⌘W ⌘Q ⌘H ⌘M in Mission Control
      missionControlImprovements = 1;
      missionControlRightClickAction = "nothing";

      # ⌥⇧C to copy Deep Link in Mail and Note
      mailCopyMessageLinkShortcut = "optionShiftC";
      notesCopyNoteLinkShortcut = "optionShiftC";

      # Unminimize windows when app becomes active
      unminimizeWindowsOnAppActivationMode = "allWindowsOnlyIfAllMinimized";

      # Disable Sparkle auto-update checks since we're managing it with Nix
      SUEnableAutomaticChecks = 0;

      # Hide the Supercharge menu bar icon
      showMenuBarIcon = 0;

      # Play a poof animation when closing a window via the red traffic-light button
      redTrafficLightButtonPoofIsEnabled = 1;

      # Keep the system Sound menu bar icon always visible (not hidden in Control Center)
      soundMenuBarIconVisibility = "always";
    };
  };
}
