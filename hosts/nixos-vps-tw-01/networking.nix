{ config, pkgs, ... }:

{
  networking.hostName = "nixos-vps-tw-01";
  networking.useDHCP = false;

  # Static IP is applied at runtime from an agenix secret
  # Secret format (shell-sourceable):
  #   IP=<address>/<prefixLength>
  #   GW=<gateway>
  age.secrets.vps-tw-01-network = {
    file = ../../secrets/vps-tw-01-network.age;
    mode = "0400";
  };

  systemd.services.configure-static-ip = {
    description = "Configure static IP from agenix secret";
    after = [ "network-pre.target" ];
    before = [
      "network.target"
      "network-online.target"
    ];
    wantedBy = [ "network-pre.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      source ${config.age.secrets.vps-tw-01-network.path}
      ${pkgs.iproute2}/bin/ip link set ens3 up
      ${pkgs.iproute2}/bin/ip addr add "$IP" dev ens3 || true
      ${pkgs.iproute2}/bin/ip route add default via "$GW" || true
    '';
  };

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    21825
  ];
  networking.firewall.allowedUDPPorts = [ 21825 ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  age.secrets.tailscale-authkey.file = ../../secrets/tailscale-authkey.age;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets."tailscale-authkey".path;
    extraUpFlags = [
      "--ssh"
      "--hostname=nixos-vps-tw-01"
    ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };
}
