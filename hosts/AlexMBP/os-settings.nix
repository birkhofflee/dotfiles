{ ... }:

# https://macos-defaults.com/
# The trick to get those configuration keys:
# $ defaults read > before
# $ defaults read > after
# $ diff before after

{
  imports = [
    ./modules/networking.nix
    ./modules/keyboard.nix
    ./modules/trackpad.nix
    ./modules/accessibility.nix
    ./modules/finder.nix
    ./modules/dock.nix
    ./modules/appearance.nix
    ./modules/screensaver.nix
    ./modules/safari.nix
    ./modules/system-apps.nix
    ./modules/third-party-apps.nix
  ];
}
