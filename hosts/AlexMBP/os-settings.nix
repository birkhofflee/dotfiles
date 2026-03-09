{ hostname, ... }:

{
  # https://macos-defaults.com/
  # The trick to get those configuration keys:
  # $ defaults read > before
  # $ defaults read > after
  # $ diff before after

  # Hostname
  networking.computerName = "${hostname}";
  networking.hostName = "${hostname}";
  system.defaults.smb.NetBIOSName = "${hostname}";

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  system.defaults = {
    # Accessibility
    universalaccess = {
      reduceMotion = true;
      reduceTransparency = false;

      # Use scroll gesture with the Ctrl (^) modifier key to zoom
      closeViewScrollWheelToggle = true;
    };

    LaunchServices = {
      # Disable quarantine for downloaded applications.
      LSQuarantine = false;
    };

    trackpad = {
      # Enable tap to click
      Clicking = true;

      # Enable three finger drag
      TrackpadThreeFingerDrag = true;
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

    dock = {
      # Do not show recent apps
      "show-recents" = false;

      # Group windows by application in Mission Control
      "expose-group-apps" = true;

      # Do not automatically rearrange spaces based on most recent use
      "mru-spaces" = false;

      # It's impossible to disable Dock, so never show it this way
      # I use Raycast so Dock is a distraction for me.
      "autohide-delay" = 1000.0;

      # Speed of the animation when hiding/showing the Dock
      "autohide-time-modifier" = 0.0;

      # Automatically hide and show the dock
      "autohide" = true;

      # Position of the dock on screen
      "orientation" = "left";

      # Size of the icons in the dock (default 64)
      "tilesize" = 40;

      # Hot Corners (wvous-*-corner)
      # 0 = no action, 1 = disabled, 2 = Mission Control, 3 = Application Windows, 4 = Desktop, 5 = Start Screen Saver, 6 = Disable Screen Saver, 7 = Dashboard, 10 = Put Display to Sleep, 11 = Launchpad, 12 = Notification Center
      "wvous-tl-corner" = 1;
      "wvous-tr-corner" = 1;
      "wvous-bl-corner" = 1;
      "wvous-br-corner" = 1;
    };

    CustomSystemPreferences = {
      NSGlobalDomain = {
        # Set system languages
        AppleLocale = "en_US";
        AppleLanguages = [
          "en-US"
          "it-IT"
          "zh-Hans-US"
          "zh-Hant-US"
        ];
        ApplePerAppLanguageSelectionBundleIdentifiers = [
          "com.apple.Music"
          "com.nssurge.surge-mac"
        ];

        AppleICUNumberSymbols = {
          "0" = ".";
          "1" = ",";
          "10" = ".";
          "17" = ",";
        };
        AppleMeasurementUnit = "Celsius";

        # 0: Caps Lock key toggles Caps Lock
        # 1: Caps Lock key switches between ABC
        TISRomanSwitchState = 0;

        NSApplicationShowExceptions = true;
      };
    };

    NSGlobalDomain = {
      # Automatically switch between light and dark mode
      AppleInterfaceStyleSwitchesAutomatically = false;

      # Trackpad: enable tap to click
      "com.apple.mouse.tapBehavior" = 1;

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
      # Disable some shortcuts
      "pbs" = {
        "NSServicesStatus" = {
          "at.EternalStorms.Yoink - Add Selected Text to Yoink - appServiceAddText" = {
            "enabled_context_menu" = 0;
            "enabled_services_menu" = 0;
            "presentation_modes" = {
              ContextMenu = 0;
              ServicesMenu = 0;
            };
          };
          "com.apple.ChineseTextConverterService - Convert Text from Simplified to Traditional Chinese - convertTextToTraditionalChinese" =
            {
              "enabled_context_menu" = 0;
              "enabled_services_menu" = 0;
              "presentation_modes" = {
                ContextMenu = 1;
                ServicesMenu = 0;
              };
            };
          "com.apple.ChineseTextConverterService - Convert Text from Traditional to Simplified Chinese - convertTextToSimplifiedChinese" =
            {
              "enabled_context_menu" = 0;
              "enabled_services_menu" = 0;
              "presentation_modes" = {
                ContextMenu = 0;
                ServicesMenu = 0;
              };
            };
          "com.apple.Safari -   Search With %WebSearchProvider@ - searchWithWebSearchProvider" = {
            "enabled_context_menu" = 0;
            "enabled_services_menu" = 0;
            "presentation_modes" = {
              ContextMenu = 0;
              ServicesMenu = 0;
            };
          };
          "com.apple.Stickies - Make Sticky - makeStickyFromTextService" = {
            "enabled_services_menu" = 0;
            "presentation_modes" = {
              ContextMenu = 0;
              ServicesMenu = 0;
            };
          };
          "com.apple.Terminal - Open man Page in Terminal - openManPage" = {
            "enabled_context_menu" = 0;
            "enabled_services_menu" = 0;
            "presentation_modes" = {
              ContextMenu = 0;
              ServicesMenu = 0;
            };
          };
          "com.apple.Terminal - Search man Page Index in Terminal - searchManPages" = {
            "enabled_context_menu" = 0;
            "enabled_services_menu" = 0;
            "presentation_modes" = {
              ContextMenu = 0;
              ServicesMenu = 0;
            };
          };
        };
      };

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
      };

      "com.apple.TextInputMenu" = {
        # Show input menu in menu bar
        visible = 1;
      };

      "com.apple.Accessibility" = {
        ReduceMotionEnabled = 1;
      };

      "com.apple.assistant.support" = {
        "Dictation Enabled" = 1;
      };

      "com.apple.CrashReporter" = {
        DialogType = "developer";
        UseUNC = true;
      };

      # Keyboard: Chinese Input Source Preferences
      "com.apple.inputmethod.CoreChineseEngineFramework" = {
        TCIMExpertDictionaryList = [
          "ExpertDict_Commerce"
          "ExpertDict_Communications"
          "ExpertDict_Computer"
          "ExpertDict_Education"
          "ExpertDict_LawPolitics"
          "ExpertDict_Industry"
        ];
        addSpacesForLatinWords = 1;
        shuangpinLayout = 4;
        shuangpinModeEnabled = 0;
      };

      "com.apple.HIToolbox" = {
        AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.ABC";
        AppleDictationAutoEnable = 1;
        AppleEnabledInputSources = [
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 252;
            "KeyboardLayout Name" = "ABC";
          }
          {
            "Bundle ID" = "com.apple.CharacterPaletteIM";
            InputSourceKind = "Non Keyboard Input Method";
          }
          {
            "Bundle ID" = "com.apple.inputmethod.ironwood";
            InputSourceKind = "Non Keyboard Input Method";
          }
          {
            "Bundle ID" = "com.apple.inputmethod.SCIM";
            InputSourceKind = "Keyboard Input Method";
          }
          {
            "Bundle ID" = "com.apple.inputmethod.SCIM";
            "Input Mode" = "com.apple.inputmethod.SCIM.Shuangpin";
            InputSourceKind = "Input Mode";
          }
          {
            "Bundle ID" = "com.apple.inputmethod.TCIM";
            InputSourceKind = "Keyboard Input Method";
          }
          {
            "Bundle ID" = "com.apple.inputmethod.TCIM";
            "Input Mode" = "com.apple.inputmethod.TCIM.Shuangpin";
            InputSourceKind = "Input Mode";
          }
          {
            "Bundle ID" = "com.apple.PressAndHold";
            InputSourceKind = "Non Keyboard Input Method";
          }
        ];
        AppleSelectedInputSources = [
          {
            "Bundle ID" = "com.apple.PressAndHold";
            InputSourceKind = "Non Keyboard Input Method";
          }
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 252;
            "KeyboardLayout Name" = "ABC";
          }
        ];
      };

      # Disable audio ducking during Dictation
      "com.apple.SpeechRecognitionCore" = {
        AllowAudioDucking = 0;
      };

      "com.apple.speech.recognition.AppleSpeechRecognition.prefs" = {
        DictationIMPreferredLanguageIdentifiers = [
          "en_GB"
          "zh_TW"
          "it_IT"
          "zh_CN"
        ];

        VisibleNetworkSRLocaleIdentifiers = {
          "en_GB" = 1;
          "it_IT" = 1;
          "zh_CN" = 1;
          "zh_TW" = 1;
        };
      };

      "com.apple.Safari.SandboxBroker" = {
        # Enable the Develop menu and the Web Inspector
        "ShowDevelopMenu" = 1;
      };

      # System Keyboard Shortcuts
      com.apple.symbolichotkeys = {
        # Record Screen (⇧⌘5)
        "184" = {
          enabled = 1;
        };

        # Default screenshot shortcuts - disable so we can use Shottr
        "28" = {
          enabled = 0;
        };

        "29" = {
          enabled = 0;
        };

        "30" = {
          enabled = 0;
        };

        "31" = {
          enabled = 0;
        };

        # Input Sources (^Space, ^⌥Space)
        "60" = {
          enabled = 1;
        };

        "61" = {
          enabled = 0;
        };

        # Disable Spotlight shortcuts (use Raycast instead)
        "64" = {
          enabled = 0;
        };

        # Disable Finder search window shortcut
        "65" = {
          enabled = 0;
        };
      };

      "com.apple.dock" = {
        "springboard-hide-duration" = 0;
        "springboard-page-duration" = 0;
        "springboard-show-duration" = 0;
      };

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

        DesktopViewSettings = {
          IconViewSettings = {
            arrangeBy = "grid"; # FIXME: doesnt work
          };
        };

        # Expand some File Info panes
        # "FXInfoPanesExpanded" = {
        #   "General" = true;
        #   "OpenWith" = true;
        #   "Privileges" = true;
        # };
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

      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network volumes
        "DSDontWriteNetworkStores" = true;

        # Avoid creating .DS_Store files on USB volumes
        "DSDontWriteUSBStores" = true;
      };

      "at.EternalStorms.Yoink" = {
        useHapticFeedback = 1;
        windowCorner = 0;
        fnToIgnore = 1;
        forceTouchAction = 2;
        setappDontShowAgain = 1;
        shouldHideOnLaunch = 0;
      };

      "com.jordanbaird.Ice" = {
        ShowIceIcon = 0;
        ShowOnClick = 1;
        ShowOnHover = 1;
        ShowOnScroll = 0;
        ShowSectionDividers = 1;
      };

      "com.nssurge.surge-mac" = {
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
      };

      # FIXME: doesn't work
      # "com.apple.Safari" = {
      #   # Press Tab to highlight each item on a web page
      #   "WebKitTabToLinksPreferenceKey" = true;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;

      #   # Show the full URL in the address bar (note: this still hides the scheme)
      #   "ShowFullURLInSmartSearchField" = true;

      #   # Prevent Safari from opening 'safe' files automatically after downloading
      #   "AutoOpenSafeDownloads" = false;

      #   # Enable continuous spellchecking
      #   "WebContinuousSpellCheckingEnabled" = true;

      #   # Disable auto-correct
      #   "WebAutomaticSpellingCorrectionEnabled" = false;

      #   # Enable warns about fraudulent websites
      #   "WarnAboutFraudulentWebsites" = true;

      #   # Enable DNT header
      #   "SendDoNotTrackHTTPHeader" = true;

      #   # Set home page to `about:blank` for faster loading
      #   "HomePage" = "about:blank";

      #   # Enable Safari's debug menu
      #   "IncludeInternalDebugMenu" = true;

      #   # Enable the Develop menu and the Web Inspector
      #   "IncludeDevelopMenu" = 1;
      #   "IncludeInternalDebugMenu" = 1;
      #   "WebKitPreferences.developerExtrasEnabled" = 1;
      #   "WebKitDeveloperExtrasEnabledPreferenceKey" = true;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;

      #   # use 1Password autofill instead of the built-in one
      #   "AutoFillCreditCardData" = 0;
      #   "AutoFillFromAddressBook" = 0;
      #   "AutoFillMiscellaneousForms" = 0;
      #   "AutoFillPasswords" = 0;
      # };
    };
  };

  # Enable sudo authentication with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  # Enable pam_reattach to allow sudo to be used with Touch ID
  security.pam.services.sudo_local.reattach = true;
}
