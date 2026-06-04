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
  };
}
