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
      "typora"
      "temurin"
      "anki"
      "arc"
      "balenaetcher"
      "betterdisplay"
      "claude"
      "cmux"
      "cursor"
      "deskpad"
      "dropbox"
      "figma"
      "ghostty"
      "linear-linear"
      "ogdesign-eagle"
      "google-chrome"
      "heptabase"
      "handbrake-app"
      "heynote"
      "obsidian"
      "iina"
      "imageoptim"
      "imazing"
      "input-source-pro"
      "keka"
      "jurplel/tap/instant-space-switcher"
      "key-codes"
      "keycastr"
      "knockknock"
      "macfuse"
      "menuwhere"
      "mounty"
      "netbirdio/tap/netbird-ui"
      "notion"
      "obs"
      "obsidian"
      "lm-studio"
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
      "thaw"
      "thebrowsercompany-dia"
      "telegram"
      "transmission"
      "transmit"
      "utm"
      "virtualbuddy"
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
      "Keynote" = 361285480;
      "LINE" = 539883307;
      "Mactracker" = 430255202;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Word" = 462054704;
      "NflxMultiSubs" = 1594059167;
      "Numbers" = 361304891;
      "Pages" = 361309726;
      "Playlisty for Apple Music" = 1459275972;
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
