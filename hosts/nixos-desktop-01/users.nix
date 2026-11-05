{
  pkgs,
  currentSystemUser,
  ...
}:

let
  keys = import ../../lib/keys.nix;
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
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NyO3jDlhxZvG1xEfAZ21i.$K2iEBoqfPs009g1mFI1Td8t00gd8/m.BIUSyFo9QqX9";
    openssh.authorizedKeys.keys = [ keys.ale ];
  };

  fonts = {
    fontDir.enable = true;
    packages = [
      pkgs.berkeley-mono
      pkgs.berkeley-mono-variable
    ];
  };

  environment.systemPackages = [ pkgs.xclip ];
}
