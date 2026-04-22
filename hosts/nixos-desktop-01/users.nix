{ config, pkgs, lib, inputs, currentSystemUser, ... }:

let
  cfg = config.nixos-desktop-01;
in
{
  time.timeZone = "Europe/Rome";

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  programs.zsh.enable = true;

  users.mutableUsers = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM"
  ];

  users.users.${currentSystemUser} = {
    isNormalUser = true;
    home = "/home/${currentSystemUser}";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NyO3jDlhxZvG1xEfAZ21i.$K2iEBoqfPs009g1mFI1Td8t00gd8/m.BIUSyFo9QqX9";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM"
    ];
  };

  fonts = {
    fontDir.enable = true;
    packages = [
      (pkgs.callPackage ../../home/packages/fonts/berkeley-mono.nix { secrets = inputs.secrets; })
      (pkgs.callPackage ../../home/packages/fonts/berkeley-mono-variable.nix { secrets = inputs.secrets; })
    ];
  };

  environment.systemPackages = with pkgs; [
    curl
    gitMinimal
    ghostty
    xclip
  ] ++ lib.optionals cfg.enableHardwareAccel [
    libva-utils      # vainfo
    pciutils         # lspci
    intel-gpu-tools  # intel_gpu_top, etc.
  ];
}
