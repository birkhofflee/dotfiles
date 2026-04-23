{
  config,
  pkgs,
  lib,
  ...
}:
{
  age.secrets.tailscale-authkey.file = ../../../../secrets/tailscale-authkey.age;

  # Fix Tailscale UDP GRO forwarding warning on ens18
  systemd.services.tailscale-ethtool = {
    description = "Configure ethtool UDP GRO forwarding for Tailscale on ens18";
    before = [ "tailscaled.service" ];
    wantedBy = [ "tailscaled.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -K ens18 rx-udp-gro-forwarding on rx-gro-list off";
      RemainAfterExit = true;
    };
  };

  # The NixOS firewall default-drops forwarded packets.
  # `openFirewall = true` only opens the Tailscale UDP port, not the FORWARD chain.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Masquerade
  networking.nat = {
    enable = true;
    internalInterfaces = [ "tailscale0" ];
    externalInterface = "ens18";
  };

  services.tailscale = {
    enable = true;
    # Enable IP forwarding & set Reverse Path Filtering (RPF) to loose
    openFirewall = true;
    authKeyFile = config.age.secrets."tailscale-authkey".path;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--advertise-routes=192.168.1.0/24"
      "--ssh"
    ];
    extraSetFlags = [
      "--advertise-exit-node"
    ];
    serve.enable = true;
  };

  # Re-run tailscale up/set when flags change (e.g. after nh os switch)
  systemd.services.tailscaled-autoconnect.restartTriggers = [
    (lib.concatStringsSep " " config.services.tailscale.extraUpFlags)
    (lib.concatStringsSep " " config.services.tailscale.extraSetFlags)
  ];
  systemd.services.tailscaled-set.restartTriggers = [
    (lib.concatStringsSep " " config.services.tailscale.extraUpFlags)
    (lib.concatStringsSep " " config.services.tailscale.extraSetFlags)
  ];
}
