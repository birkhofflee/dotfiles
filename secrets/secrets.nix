let
  ale = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0762tms0QT6kCQ7tTgoOdm+ry29ImKgDk09hXurEfM";
  users = [ ale ];

  # ssh-keyscan -t ed25519 homelab-nuc
  homelab-nuc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFD2LZIYz9eBmt3W+rALfdC3LEkyaYKUYO9Pkecxh4iN";
  systems = [ homelab-nuc ];
in
{
  "armored-tailscale-authkey.age" = {
    publicKeys = [
      ale
      homelab-nuc
    ];
    armor = true;
  };
  "armored-ssh-config.age" = {
    publicKeys = [
      ale
    ];
    armor = true;
  };
  # "secret2.age".publicKeys = users ++ systems;
  # "armored-secret.age" = {
  #   publicKeys = [ ale ];
  #   armor = true;
  # };
}
