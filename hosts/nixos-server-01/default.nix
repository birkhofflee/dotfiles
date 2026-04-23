{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}:

let
  username = "ale";
  hostname = "nixos-server-01";
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../shared-nix-settings.nix
    ./disk-config.nix

    ../common-system-packages.nix

    ./services/tailscale
    ./services/atuin
    ./services/rybbit
    ./services/caddy
    ./services/cloudflared
    ./services/apex-discord-bot
    ./services/jupyter
  ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.loader.grub = {
    enable = lib.mkDefault true;
    devices = lib.mkDefault [ "nodev" ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  boot.growPartition = true;

  services.qemuGuest.enable = true;

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

  # Periodic TRIM for thin-provisioned PVE storage (pairs with discard=on on scsi0)
  services.fstrim.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  programs.zsh.enable = true; # Enable zsh system-wide
  virtualisation.podman.enable = true;

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
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NyO3jDlhxZvG1xEfAZ21i.$K2iEBoqfPs009g1mFI1Td8t00gd8/m.BIUSyFo9QqX9";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  system.stateVersion = "24.05";
}
