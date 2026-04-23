{
  pkgs,
  lib,
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
    customSettings = {
      # flake-registry = "/etc/nix/flake-registry.json";
      # sandbox = true;
      trusted-users = [
        "@admin"
        "${username}"
        "root"
      ];
    };
  };

  documentation.enable = false;

  networking = {
    applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      # allowSigned = true; # Whether to enable built-in software to receive incoming connections.
      # allowSignedApp = true; # Whether to enable downloaded signed software to receive incoming connections.
      # blockAllIncoming = true; # Whether to enable blocking all incoming connections.
    };
  };

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  nix.settings = {
    # https://github.com/NixOS/nix/issues/7273
    auto-optimise-store = false;

    extra-platforms = lib.mkIf (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };

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
        echo "[+] Installing Homebrew"
        su -l ${username} -c '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
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
