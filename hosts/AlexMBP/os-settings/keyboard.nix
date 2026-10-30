{ ... }:

{
  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  system.defaults = {
    NSGlobalDomain = {
      # Disable autocapitalization at sentence starts
      NSAutomaticCapitalizationEnabled = false;

      # Disable smart dashes (-- → —)
      NSAutomaticDashSubstitutionEnabled = false;

      # Disable double-space to period substitution
      NSAutomaticPeriodSubstitutionEnabled = false;

      # Disable smart quotes (' ' " " → straight apostrophes/quotes)
      NSAutomaticQuoteSubstitutionEnabled = false;

      # Disable inline autocorrect
      NSAutomaticSpellingCorrectionEnabled = false;

      # Keep press-and-hold accent picker enabled (needed for Italian accents on ABC layout)
      ApplePressAndHoldEnabled = true;

      # Delay before key repeat begins (units of 16.67 ms; 15 ≈ 225 ms)
      InitialKeyRepeat = 15;

      # Key repeat interval once repeating starts (units of 16.67 ms; 2 ≈ 30 ms)
      KeyRepeat = 2;
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
          "com.wuziqi.SenPlayer"
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

      "com.apple.TextInputMenu" = {
        # Show input menu in menu bar
        visible = 1;
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

      # System Keyboard Shortcuts
      com.apple.symbolichotkeys = {
        # Record Screen (Shift+Cmd+5)
        "184" = {
          enabled = 1;
        };

        # Disable default screenshot shortcuts to use Shottr
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

        # Disable toggle Dock hiding (⌥⌘D)
        "52" = {
          enabled = 0;
        };

        # Disable Mission Control: Move left/right a space (^← / ^→)
        # Using Raycast's counterparts so there are no animations
        "79" = {
          enabled = 0;
        };

        "81" = {
          enabled = 0;
        };

        # Not sure
        "59" = {
          enabled = 0;
        };

        "162" = {
          enabled = 0;
        };

        # Disable Accessibility shortcuts (zoom, contrast, invert colors, etc.)
        "215" = {
          enabled = 0;
        };

        "216" = {
          enabled = 0;
        };

        "217" = {
          enabled = 0;
        };

        "218" = {
          enabled = 0;
        };

        "219" = {
          enabled = 0;
        };

        "225" = {
          enabled = 0;
        };

        "226" = {
          enabled = 0;
        };

        "227" = {
          enabled = 0;
        };

        "228" = {
          enabled = 0;
        };

        "229" = {
          enabled = 0;
        };

        "230" = {
          enabled = 0;
        };

        "231" = {
          enabled = 0;
        };

        "232" = {
          enabled = 0;
        };

        # Disable Game Overlay (⌘⎋) - used for Ghostty quick terminal
        "260" = {
          enabled = 0;
        };
      };
    };
  };
}
