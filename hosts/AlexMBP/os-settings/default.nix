{ ... }:

# https://macos-defaults.com/
# The trick to get those configuration keys:
# $ defaults read > before
# $ defaults read > after
# $ diff before after

{
  imports = [
    ./networking.nix
    ./keyboard.nix
    ./trackpad.nix
    ./accessibility.nix
    ./finder.nix
    ./dock.nix
    ./appearance.nix
    ./screensaver.nix
    ./safari.nix
    ./system-apps.nix
    ./third-party-apps.nix
  ];
}
