{
  # Homebrew has to be installed first.
  # This installs brew packages and Mac App Store apps.
  homebrew = {
    enable = true;

    brews = [
      "mas"
      # "carthage"
      "displayplacer"
      "hopenpgp-tools"
      "screenresolution"
    ];

    casks = [
      "1password"
      "1password-cli"
      "temurin"
      "anki"
      "arc"
      "balenaetcher"
      "betterdisplay"
      "claude"
      "cursor"
      "deskpad"
      "dropbox"
      "figma"
      "ghostty"
      "ogdesign-eagle"
      "google-chrome"
      "heptabase"
      "handbrake-app"
      "heynote"
      "iina"
      "imageoptim"
      "imazing"
      "input-source-pro"
      "jordanbaird-ice"
      "keka"
      "key-codes"
      "keycastr"
      "knockknock"
      "macfuse"
      "menuwhere"
      "mounty"
      "notion"
      "obs"
      "obsidian"
      "orbstack"
      "quicklook-csv"
      "quicklook-json"
      "raycast"
      "shottr"
      "spotify"
      "steam"
      "sublime-text"
      "superwhisper"
      "suspicious-package"
      "teamviewer"
      "thebrowsercompany-dia"
      "telegram"
      "transmission"
      "transmit"
      "utm"
      "visual-studio-code"
      "visual-studio-code@insiders"
      "vorta"
      "wechat"
      "wifi-explorer"
      "winbox"
      "wireshark-app"
      "zed"
      "zoom"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Actions" = 1586435171;
      "AmorphousDiskMark" = 1168254295;
      "BrightIntosh" = 6452471855;
      "CrystalFetch" = 6454431289;
      "DaisyDisk" = 411643860;
      "Gifski" = 1351639930;
      "Goodnotes" = 1444383602;
      "Hyperduck" = 6444667067;
      "Infuse" = 1136220934;
      "Keynote" = 409183694;
      "LINE" = 539883307;
      "Mactracker" = 430255202;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      "NflxMultiSubs" = 1594059167;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Playlisty Apple Music" = 1459275972;
      "Second Clock" = 6450279539;
      "SenPlayer" = 6443975850;
      "Slack" = 803453959;
      "Tailscale" = 1475387142;
      "The Unarchiver" = 425424353;
      "WhatsApp" = 310633997;
      "WireGuard" = 1451685025;
      "Xcode" = 497799835;
      "Yoink" = 457622435;
    };
  };
}
