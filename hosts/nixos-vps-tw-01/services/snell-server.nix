{ pkgs, config, ... }:

{
  age.secrets."snell-server.conf" = {
    file = ../../../secrets/snell-server.conf.age;
    mode = "0444";
  };

  systemd.services.snell = {
    description = "Snell Proxy Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Group = "nogroup";
      DynamicUser = true;
      LimitNOFILE = 32768;
      ExecStart = "${pkgs.snell}/bin/snell-server -c ${config.age.secrets."snell-server.conf".path}";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "snell-server";
      Restart = "on-failure";
    };
  };
}
