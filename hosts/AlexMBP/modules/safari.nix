{ ... }:

{
  system.defaults.CustomUserPreferences = {
    "com.apple.Safari.SandboxBroker" = {
      # Enable the Develop menu and the Web Inspector
      "ShowDevelopMenu" = 1;
    };

    # This requires Full Disk Access granted to the terminal app.
    "com.apple.Safari" = {
      # Press Tab to highlight each item on a web page
      "WebKitTabToLinksPreferenceKey" = true;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;

      # Show the full URL in the address bar (note: this still hides the scheme)
      "ShowFullURLInSmartSearchField" = true;

      # Prevent Safari from opening 'safe' files automatically after downloading
      "AutoOpenSafeDownloads" = false;

      # Enable continuous spellchecking
      "WebContinuousSpellCheckingEnabled" = true;

      # Disable auto-correct
      "WebAutomaticSpellingCorrectionEnabled" = false;

      # Enable warns about fraudulent websites
      "WarnAboutFraudulentWebsites" = true;

      # Enable DNT header
      "SendDoNotTrackHTTPHeader" = true;

      # Set home page to `about:blank` for faster loading
      "HomePage" = "about:blank";

      # Enable Safari's debug menu
      "IncludeInternalDebugMenu" = true;

      # Enable the Develop menu and the Web Inspector
      "IncludeDevelopMenu" = 1;
      "WebKitPreferences.developerExtrasEnabled" = 1;
      "WebKitDeveloperExtrasEnabledPreferenceKey" = true;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;

      # use 1Password autofill instead of the built-in one
      "AutoFillCreditCardData" = 0;
      "AutoFillFromAddressBook" = 0;
      "AutoFillMiscellaneousForms" = 0;
      "AutoFillPasswords" = 0;
    };
  };
}
