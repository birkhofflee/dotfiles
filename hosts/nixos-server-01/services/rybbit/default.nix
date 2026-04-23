{ config, pkgs, ... }:

let
  clickhouseDb = "analytics";
  clickhouseUser = "default";
  clickhousePassword = "frog";
  postgresUser = "frog";
  postgresPassword = "frog";
  postgresDb = "analytics";
  baseUrl = "https://analytics.birkhoff.me";

  networkName = "rybbit";

  chNetwork = pkgs.writeText "ch-network.xml" ''
    <clickhouse>
      <listen_host>0.0.0.0</listen_host>
    </clickhouse>
  '';

  chJson = pkgs.writeText "ch-json.xml" ''
    <clickhouse>
      <settings>
        <enable_json_type>1</enable_json_type>
      </settings>
    </clickhouse>
  '';

  chLogging = pkgs.writeText "ch-logging.xml" ''
    <clickhouse>
      <logger>
        <level>warning</level>
        <console>true</console>
      </logger>
      <query_thread_log remove="remove"/>
      <query_log remove="remove"/>
      <text_log remove="remove"/>
      <trace_log remove="remove"/>
      <metric_log remove="remove"/>
      <asynchronous_metric_log remove="remove"/>
      <session_log remove="remove"/>
      <part_log remove="remove"/>
      <latency_log remove="remove"/>
      <processors_profile_log remove="remove"/>
    </clickhouse>
  '';

  chUserLogging = pkgs.writeText "ch-user-logging.xml" ''
    <clickhouse>
      <profiles>
        <default>
          <log_queries>0</log_queries>
          <log_query_threads>0</log_query_threads>
          <log_processors_profiles>0</log_processors_profiles>
        </default>
      </profiles>
    </clickhouse>
  '';
in
{
  services.caddy.virtualHosts."http://analytics.birkhoff.me" = {
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

  age.secrets.rybbit-auth-secret = {
    file = ../../../../secrets/rybbit-auth-secret.age;
  };

  # Create Podman network before any container starts
  systemd.services.podman-create-rybbit-network = {
    description = "Create Podman network for Rybbit";
    before = [
      "podman-rybbit-clickhouse.service"
      "podman-rybbit-postgres.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.podman}/bin/podman network create ${networkName} || true'";
    };
  };

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {

    rybbit-clickhouse = {
      image = "clickhouse/clickhouse-server:25.4.2";
      volumes = [
        "rybbit-clickhouse-data:/var/lib/clickhouse"
        "${chNetwork}:/etc/clickhouse-server/config.d/network.xml:ro"
        "${chJson}:/etc/clickhouse-server/config.d/enable_json.xml:ro"
        "${chLogging}:/etc/clickhouse-server/config.d/logging_rules.xml:ro"
        "${chUserLogging}:/etc/clickhouse-server/config.d/user_logging.xml:ro"
      ];
      environment = {
        CLICKHOUSE_DB = clickhouseDb;
        CLICKHOUSE_USER = clickhouseUser;
        CLICKHOUSE_PASSWORD = clickhousePassword;
      };
      extraOptions = [ "--network=${networkName}" ];
    };

    rybbit-postgres = {
      image = "postgres:17.4";
      volumes = [ "rybbit-postgres-data:/var/lib/postgresql/data" ];
      environment = {
        POSTGRES_USER = postgresUser;
        POSTGRES_PASSWORD = postgresPassword;
        POSTGRES_DB = postgresDb;
      };
      extraOptions = [ "--network=${networkName}" ];
    };

    rybbit-backend = {
      image = "ghcr.io/rybbit-io/rybbit-backend:latest";
      ports = [ "127.0.0.1:3001:3001" ];
      # rybbit-auth-secret.age must contain: BETTER_AUTH_SECRET=<value>
      environmentFiles = [ config.age.secrets.rybbit-auth-secret.path ];
      environment = {
        NODE_ENV = "production";
        CLICKHOUSE_HOST = "http://rybbit-clickhouse:8123";
        CLICKHOUSE_DB = clickhouseDb;
        CLICKHOUSE_PASSWORD = clickhousePassword;
        POSTGRES_HOST = "rybbit-postgres";
        POSTGRES_PORT = "5432";
        POSTGRES_DB = postgresDb;
        POSTGRES_USER = postgresUser;
        POSTGRES_PASSWORD = postgresPassword;
        BASE_URL = baseUrl;
        DISABLE_SIGNUP = "true";
        DISABLE_TELEMETRY = "true";
      };
      extraOptions = [ "--network=${networkName}" ];
      dependsOn = [
        "rybbit-clickhouse"
        "rybbit-postgres"
      ];
    };

    rybbit-client = {
      image = "ghcr.io/rybbit-io/rybbit-client:latest";
      ports = [ "127.0.0.1:3002:3002" ];
      environment = {
        NODE_ENV = "production";
        NEXT_PUBLIC_BACKEND_URL = baseUrl;
        NEXT_PUBLIC_DISABLE_SIGNUP = "true";
      };
      extraOptions = [ "--network=${networkName}" ];
      dependsOn = [ "rybbit-backend" ];
    };

  };
}
