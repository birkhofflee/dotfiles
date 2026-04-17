{
  services.atuin = {
    enable = true;
    host = "127.0.0.1";
    port = 8010;
    openRegistration = true;
  };

  services.tailscale.serve.services.atuin = {
    advertised = true;
    endpoints = {
      "tcp:80" = "http://localhost:8010";
    };
  };
}
