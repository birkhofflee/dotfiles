{ config, inputs, ... }:

{
  networking.hostName = "nixos-desktop-01";
  networking.networkmanager.enable = true; # DHCP

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    3389
  ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  age.secrets.tailscale-authkey.file = ../../secrets/tailscale-authkey.age;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets."tailscale-authkey".path;
    extraUpFlags = [ "--ssh" ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
    # Pre-seed the SSH host key so agenix can decrypt secrets on first boot.
    # ssh-keygen -t ed25519 -N "" -f hosts/nixos-desktop-01/ssh_host_ed25519_key
    #
    # The private key lives in dotfiles.secret (private repo)
    hostKeys = [
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
      }
    ];
  };

  environment.etc = {
    "ssh/ssh_host_ed25519_key" = {
      source = "${inputs.secrets}/ssh-host-keys/nixos-desktop-01/ssh_host_ed25519_key";
      mode = "0600";
    };
    "ssh/ssh_host_ed25519_key.pub" = {
      source = "${inputs.secrets}/ssh-host-keys/nixos-desktop-01/ssh_host_ed25519_key.pub";
      mode = "0644";
    };
  };
}
