{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    ack
    bashInteractive
    cmake
    curl
    dialog
    foremost
    git
    mtr
    ncdu
    openssh
    ruby
    screen
    wget
    zsh
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
    ghostty.terminfo
  ];
}
