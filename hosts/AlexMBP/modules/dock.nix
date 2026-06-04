{ ... }:

{
  system.defaults = {
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

    CustomUserPreferences = {
      "com.apple.dock" = {
        "springboard-hide-duration" = 0;
        "springboard-page-duration" = 0;
        "springboard-show-duration" = 0;
      };
    };
  };
}
