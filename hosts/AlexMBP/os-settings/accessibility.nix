{ ... }:

{
  system.defaults = {
    universalaccess = {
      reduceMotion = true;
      reduceTransparency = false;

      # Use scroll gesture with the Ctrl (^) modifier key to zoom
      closeViewScrollWheelToggle = true;
    };

    CustomUserPreferences = {
      "com.apple.Accessibility" = {
        ReduceMotionEnabled = 1;
      };

      "com.apple.universalaccess" = {
        # Disable keyboard shortcuts for zoom (⌥⌘= / ⌥⌘- etc.); those keys are used elsewhere
        closeViewHotkeysEnabled = 0;
      };
    };
  };
}
