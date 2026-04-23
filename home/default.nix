# Shared full-featured home config used by most hosts (macOS and NixOS).
# Platform-agnostic: loads all files under ./programs and ./files.

{ pkgs, lib, ... }:

let
  # List of all .nix files in ./programs, excluding opt-in modules
  programImports = builtins.map (file: ./programs/${file}) (
    builtins.filter (f: lib.hasSuffix ".nix" f && f != "1password.nix") (builtins.attrNames (builtins.readDir ./programs))
  );

  # List of all .nix files in ./files
  fileImports = builtins.map (file: ./files/${file}) (
    builtins.filter (f: lib.hasSuffix ".nix" f) (builtins.attrNames (builtins.readDir ./files))
  );

  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  setWallpaperScript = lib.optionals isDarwin (import ./libs/wallpaper.nix { inherit pkgs; });
in
rec {
  home.stateVersion = "23.11";

  home.username = "ale";
  home.homeDirectory = if isDarwin then "/Users/${home.username}" else "/home/${home.username}";

  # This sets up env vars `XDG_CACHE_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME` and `XDG_STATE_HOME`
  # @see https://github.com/nix-community/home-manager/blob/master/modules/misc/xdg.nix
  xdg.enable = true;

  manual.manpages.enable = false;

  imports = [
    ./packages/user-packages.nix
  ]
  ++ programImports
  ++ fileImports
  # 1Password is opt-in: imported here for macOS (always available), and
  # explicitly imported in custom home configs (e.g. nixos-desktop-01).
  ++ lib.optionals isDarwin [ ./programs/1password.nix ];

  # Expressions like $HOME are expanded by the shell.
  # However, since expressions like ~ or * are escaped,
  # they will end up in the PATH verbatim.
  #
  # `tv path` is useful to inspect the binaries in PATHs.
  # @see https://nix-community.github.io/home-manager/options.xhtml#opt-home.sessionPath
  home.sessionPath = [
    # Rust
    "${home.homeDirectory}/.cargo/bin"
    # Golang
    "${home.homeDirectory}/go/bin"
    # uv tool
    "${home.homeDirectory}/.local/bin"
  ]
  ++ lib.optionals isDarwin [
    # macOS-specific paths

    # Homebrew (env vars are hardcoded in zsh.nix profileExtra for performance)
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    # Apple
    "/Library/Apple/usr/bin"
    # Wireshark
    "/Applications/Wireshark.app/Contents/MacOS"
  ];

  # macOS-specific activation scripts - skipped for NixOS
  home.activation = lib.mkIf isDarwin {
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
