{ config, pkgs, ... }:
{
  # analytics.birkhoff.me
  # https://one.dash.cloudflare.com/5596ba9c6b5ba1d0d3e7fbcbe2a53349/networks/connectors/cloudflare-tunnels/cfd_tunnel/f2c7773c-4c3d-4862-829f-89e647da8fbc/edit?tab=publicHostname

  # secret file must contain: TUNNEL_TOKEN=<token>
  age.secrets.cloudflared-creds = {
    file = ../../../../secrets/cloudflared-creds.age;
  };

  systemd.services.cloudflared = {
    description = "Cloudflare Tunnel";
    after = [ "network.target" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      EnvironmentFile = config.age.secrets.cloudflared-creds.path;
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run";
      Restart = "on-failure";
    };
  };
}
