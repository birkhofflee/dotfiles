let
  ale = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM";
  nixos-desktop-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJIzDz6of9lrchRhiMfr3yChjJrv6LZ5hhpwmDkAa37o"; # gh:birkhofflee/dotfiles.secret ssh-host-keys/nixos-desktop-01
  myHosts = [
    ale
    nixos-desktop-01
  ];
in
# nixos-server-01's host key is deliberately absent. That host is configured
# from ~/Documents/Infrastructure/Homelab, which carries its credentials as
# plain files under secrets/ rather than agenix, so nothing here needs to be
# decryptable by it. The five secrets it was the only consumer of
# (cachix-token, cloudflared-creds, rybbit-auth-secret, jupyter-token,
# apex-discord-bot) were removed along with the host.
{
  "tailscale-authkey.age" = {
    publicKeys = myHosts;
    armor = true;
  };
  "ssh-config.age" = {
    publicKeys = [
      ale
    ];
    armor = true;
  };
  "mcp-env.age" = {
    publicKeys = [
      ale
    ];
    armor = true;
  };
}
