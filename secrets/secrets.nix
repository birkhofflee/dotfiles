let
  ale = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM";
  nixos-server-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIORLVEJT3P3Vh92bUrZ/nBTewG+KBZFWu6O6T4uva+GM";

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
    publicKeys = withHomelab;
    armor = true;
  };
  "ssh-config.age" = {
    publicKeys = [
      ale
    ];
    armor = true;
  };
}
