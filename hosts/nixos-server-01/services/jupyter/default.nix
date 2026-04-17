{ config, pkgs, ... }:
{
  age.secrets.jupyter-token = {
    file = ../../../../secrets/jupyter-token.age;
    owner = "root";
  };

  virtualisation.oci-containers.containers.jupyter = {
    image = "quay.io/jupyter/scipy-notebook:latest";
    ports = [ "127.0.0.1:8888:8888" ];
    volumes = [
      "/home/jupyter/notebooks:/home/jovyan/work"
      "${pkgs.uv}/bin/uv:/usr/local/bin/uv:ro"
    ];
    user = "1000:100";
    environmentFiles = [ config.age.secrets.jupyter-token.path ];
    cmd = [
      "start-notebook.py"
      "--ServerApp.allow_remote_access=True"
      "--ServerApp.root_dir=/home/jovyan/work"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /home/jupyter/notebooks 0750 1000 100 -"
  ];

  services.tailscale.serve.services.jupyter = {
    advertised = true;
    endpoints = {
      "tcp:80" = "http://localhost:8888";
    };
  };
}
