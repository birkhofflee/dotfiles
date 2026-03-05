{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  username = "ale";
  hostname = "homelab-nuc";
in
{
  imports = [
    ../shared-nix-settings.nix
    ./disk-config.nix

    ./services/tailscale
    ./services/atuin
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
    # The /boot (ESP) partition is only 127M (should be 512M — fix on next reinstall
    # via nixos-anywhere by updating disk-config.nix). Each kernel+initrd pair is ~45MB,
    # so keeping more than 2 generations fills the partition. This also ensures the
    # bootloader installer only copies kernel files for the last N configs, preventing
    # "no space left on device" errors when old generations accumulate.
    configurationLimit = 2;
  };

  # For a small server, disk swap is fine but slow; zram creates a compressed
  # swap space in RAM, trading a little CPU for much faster “swap.” It reduces SSD
  # wear and usually keeps the system responsive under memory pressure.
  zramSwap = {
    enable = true;
    memoryPercent = 75;
    algorithm = "zstd"; # or "lz4" for slightly faster, less compression
  };

  # Networking
  networking.hostName = hostname;

  time.timeZone = "Europe/Rome";

  environment.systemPackages = with pkgs; [
    curl
    gitMinimal
    ghostty.terminfo
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  programs.zsh.enable = true; # Enable zsh system-wide
  virtualisation.docker.enable = true;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM"
  ];

  # User configuration
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NyO3jDlhxZvG1xEfAZ21i.$K2iEBoqfPs009g1mFI1Td8t00gd8/m.BIUSyFo9QqX9";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # helix
  # ghostty

  system.stateVersion = "24.05";
}
