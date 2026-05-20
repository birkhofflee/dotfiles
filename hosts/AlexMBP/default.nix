{
  pkgs,
  currentSystemUser,
  ...
}:

let
  username = currentSystemUser;
  hostname = "AlexMBP";
in
{
  system.primaryUser = "${username}";

  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
  };

  imports = [
    ../shared-nix-settings.nix
    ../common-system-packages.nix

    (import ./os-settings.nix ({ inherit hostname; }))
    ./packages/homebrew.nix
    ./ssh-config.nix
  ];

  determinateNix = {
    # Enable Determinate Nix to handle the Nix configuration rather than nix-darwin
    enable = true;

    # Custom settings written to /etc/nix/nix.custom.conf
    # Note: nix.settings is ignored when determinateNix.enable = true; use customSettings instead.
    customSettings = {
      # flake-registry = "/etc/nix/flake-registry.json";
      # sandbox = true;
      trusted-users = [
        "@admin"
        "${username}"
        "root"
      ];
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://helix.cachix.org"
        "https://birkhoff.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "birkhoff.cachix.org-1:m7WmdU7PKc6fsKedC278lhLtiqjz6ZUJ6v2nkVGyJjQ="
      ];
    };
  };

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  # Load nix-darwin in /etc/zshrc.
  programs.zsh.enable = true;

  # https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/activation-scripts.nix#L83
  system.activationScripts = {
    "preActivation".text = ''
      if ! /usr/bin/pgrep -q oahd >/dev/null 2>&1; then
        echo "[+] Installing Rosetta"
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
      fi

      if ! [[ -f "/opt/homebrew/bin/brew" ]] && ! [[ -f "/usr/local/bin/brew" ]]; then
        echo '[!] Homebrew not found - install manually by running `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`'
        exit 1
      fi
    '';

    "postActivation".text = ''
      if ! sudo launchctl list | grep -q com.apple.locate; then
        echo "[+] Creating database for locate command"
        sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
      fi

      echo "[+] Revealing /Volumes"
      chflags nohidden /Volumes
    '';
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # https://github.com/LnL7/nix-darwin/blob/master/CHANGELOG
  system.stateVersion = 6;
}
