# macOS home config for AlexMBP.
# Imports the shared home base and adds macOS-specific programs, packages,
# session paths, and activation scripts.

{
  pkgs,
  lib,
  config,
  ...
}:

let
  # List of all .nix files in home/files
  # TODO: refactor this pattern
  fileImports = builtins.map (file: ../../home/files/${file}) (
    builtins.filter (f: lib.hasSuffix ".nix" f) (builtins.attrNames (builtins.readDir ../../home/files))
  );

  setWallpaperScript = import ../../home/libs/wallpaper.nix { inherit pkgs; };
in
{
  imports = [
    ../../home
    ../../home/programs/1password.nix
    ../../home/programs/ghostty.nix
    ./packages/user-packages.nix
  ]
  ++ fileImports;

  # Expressions like $HOME are expanded by the shell.
  # However, since expressions like ~ or * are escaped,
  # they will end up in the PATH verbatim.
  #
  # `tv path` is useful to inspect the binaries in PATHs.
  # @see https://nix-community.github.io/home-manager/options.xhtml#opt-home.sessionPath
  home.sessionPath = [
    # Rust
    "${config.home.homeDirectory}/.cargo/bin"
    # Golang
    "${config.home.homeDirectory}/go/bin"
    # uv tool
    "${config.home.homeDirectory}/.local/bin"
    # macOS-specific paths

    # Homebrew (env vars are hardcoded in zsh.nix profileExtra for performance)
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    # Apple
    "/Library/Apple/usr/bin"
    # Wireshark
    "/Applications/Wireshark.app/Contents/MacOS"
  ];

  home.activation = {
    "revealHomeLibraryDirectory" = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /usr/bin/chflags nohidden "$HOME/Library"
    '';

    "setWallpaper" = lib.hm.dag.entryAfter [ "revealHomeLibraryDirectory" ] ''
      echo "[+] Setting wallpaper"
      ${setWallpaperScript}/bin/set-wallpaper-script
    '';

    "activateUserSettings" = lib.hm.dag.entryAfter [ "setWallpaper" ] ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      for app in \
        "Activity Monitor" \
        "cfprefsd" \
        "ControlStrip" \
        "Dock" \
        "Photos" \
        "replayd" \
        "SystemUIServer" \
        "TextInputMenuAgent" \
        "WindowManager"; do
        /usr/bin/killall "''${app}" &> /dev/null && echo "[+] Killed ''${app}" || true
      done
    '';
  };
}
