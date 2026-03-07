let
  ale = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM";
  # ssh-keyscan -t ed25519 homelab-nuc
  homelab-nuc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFD2LZIYz9eBmt3W+rALfdC3LEkyaYKUYO9Pkecxh4iN";

  withHomelab = [ ale homelab-nuc ];
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
