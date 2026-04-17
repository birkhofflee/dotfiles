{ config, pkgs, ... }:
{
  age.secrets.tailscale-authkey.file = ../../../../secrets/tailscale-authkey.age;

  services.tailscale = {
    enable = true;
    package = pkgs.pkgs-unstable.tailscale;
    openFirewall = true;
    authKeyFile = config.age.secrets."tailscale-authkey".path;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--advertise-routes=192.168.0.0/24"
    ];
    extraSetFlags = [
      "--advertise-exit-node"
    ];
    serve.enable = true;
  };
}
