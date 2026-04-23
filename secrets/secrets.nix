let
  ale = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM";
  nixos-server-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIORLVEJT3P3Vh92bUrZ/nBTewG+KBZFWu6O6T4uva+GM";
  nixos-desktop-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIzDz6of9lrchRhiMfr3yChjJrv6LZ5hhpwmDkAa37o"; # gh:birkhofflee/dotfiles.secret ssh-host-keys/nixos-desktop-01
  nixos-vps-tw-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVD+LyFUS45DlWEzzniJsv2NQh0ro7GZ2bAdyDpAAad";

  withHomelab = [ ale nixos-server-01 ];
in
{
  "rybbit-auth-secret.age" = {
    publicKeys = withHomelab;
    armor = true;
  };
  "cloudflared-creds.age" = {
    publicKeys = withHomelab;
    armor = true;
  };
  "tailscale-authkey.age" = {
    publicKeys = withHomelab ++ [ nixos-desktop-01 nixos-vps-tw-01 ];
    armor = true;
  };
  "apex-discord-bot.age" = {
    publicKeys = withHomelab;
    armor = true;
  };
  "jupyter-token.age" = {
    publicKeys = withHomelab;
    armor = true;
  };
  "ssh-config.age" = {
    publicKeys = [
      ale
    ];
    armor = true;
  };
  "vps-tw-01-network.age" = {
    publicKeys = [ ale nixos-vps-tw-01 ];
    armor = true;
  };
  "snell-server.conf.age" = {
    publicKeys = [ ale nixos-vps-tw-01 ];
    armor = true;
  };
}
