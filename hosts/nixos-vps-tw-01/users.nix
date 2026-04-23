{ pkgs, currentSystemUser, ... }:

{
  time.timeZone = "Asia/Taipei";

  security.sudo.wheelNeedsPassword = false;

  i18n.defaultLocale = "en_US.UTF-8";

  programs.zsh.enable = true;

  users.mutableUsers = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM"
  ];

  users.users.${currentSystemUser} = {
    isNormalUser = true;
    home = "/home/${currentSystemUser}";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$NyO3jDlhxZvG1xEfAZ21i.$K2iEBoqfPs009g1mFI1Td8t00gd8/m.BIUSyFo9QqX9";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM"
    ];
  };

  environment.systemPackages = with pkgs; [
    curl
    gitMinimal
    ghostty.terminfo
  ];
}
