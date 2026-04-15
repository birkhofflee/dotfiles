{ ... }:
{
  services.caddy = {
    enable = true;
    virtualHosts."http://analytics.birkhoff.me" = {
      extraConfig = ''
        encode zstd gzip

        request_body max_size 10MB

        handle /api/* {
          reverse_proxy localhost:3001
        }

        handle {
          reverse_proxy localhost:3002
        }
      '';
    };
  };
}
