{ ... }:

{
  system.defaults = {
    trackpad = {
      # Enable tap to click
      Clicking = true;

      # Enable three finger drag
      TrackpadThreeFingerDrag = true;
    };

    NSGlobalDomain = {
      # Trackpad: enable tap to click
      "com.apple.mouse.tapBehavior" = 1;
    };

    CustomUserPreferences = {
      "com.apple.AppleMultitouchTrackpad" = {
        # Two-finger tap for right click
        TrackpadRightClick = 1;

        # No corner secondary click (right click comes from two-finger tap only)
        TrackpadCornerSecondaryClick = 0;

        # Keep scroll momentum after lifting fingers (flick-to-scroll)
        TrackpadMomentumScroll = 1;

        # Two-finger double-tap to zoom into a web page or PDF (smart zoom)
        TrackpadTwoFingerDoubleTapGesture = 1;

        # Swipe from right edge with two fingers to open Notification Center
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      };
    };
  };
}
