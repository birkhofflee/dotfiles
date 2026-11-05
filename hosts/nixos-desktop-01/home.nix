{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ../../home
    ../../home/modules/1password.nix
    ../../home/modules/ghostty.nix
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };

  home.packages = with pkgs; [
    # ── Shell & terminal ───────────────────────────────────────────────────
    glow # render Markdown

    # ── Developer tools ────────────────────────────────────────────────────
    just
    git-open # `git open` to open the GitHub page
    gh # GitHub CLI

    # ── Nix tooling ────────────────────────────────────────────────────────
    nil # Nix LSP
    yaml-language-server

    # ── Desktop utilities ──────────────────────────────────────────────────
    libnotify # provides notify-send (required by zsh-auto-notify)
    xdg-utils
  ];

  programs.firefox = {
    enable = true;

    # Adopt the XDG layout that home-manager makes the default at
    # home.stateVersion 26.05. `configPath` feeds `home.file.<name>`, so it must
    # stay relative to $HOME — this mirrors upstream's own default expression.
    configPath = "${lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome}/mozilla/firefox";

    profiles.default = { };

    # Installed by policy from addons.mozilla.org, which keeps it current without
    # pulling in NUR for this one extension.
    policies.ExtensionSettings."{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
      installation_mode = "force_installed";
    };
  };
}
