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
      "anki"
      "arc"
      "autodesk-fusion"
      "balenaetcher"
      "betterdisplay"
      "blender"
      "chatgpt"
      "claude"
      "cmux"
      "cursor"
      "deskpad"
      "discord"
      "dropbox"
      "figma"
      "ghostty"
      "google-chrome"
      "handbrake-app"
      "helium-browser"
      "heptabase"
      "heynote"
      "iina"
      "imageoptim"
      "imazing"
      "input-source-pro"
      "jurplel/tap/instant-space-switcher"
      "keka"
      "key-codes"
      "keycastr"
      "knockknock"
      "lm-studio"
      "macfuse"
      "menuwhere"
      "mounty"
      "netbirdio/tap/netbird-ui"
      "notion"
      "obs"
      "obsidian"
      "ogdesign-eagle"
      "orbstack"
      "orion"
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
      "telegram"
      "temurin"
      "thaw"
      "thebrowsercompany-dia"
      "transmission"
      "transmit"
      "typora"
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
      "Windows App" = 1295203466;
      "WireGuard" = 1451685025;
      "Xcode" = 497799835;
      "Yoink" = 457622435;
    };
  };
}
