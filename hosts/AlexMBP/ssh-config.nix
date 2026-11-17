{
  pkgs,
  lib,
  currentSystemUser,
  ...
}:
let
  username = currentSystemUser;
in
{
  home-manager.users.${username} = {
    age.package = pkgs.age-with-plugins;
    age.identityPaths = [ "${./age-identity.txt}" ];

    # The default is $TMPDIR (/var/folders/.../T), which macOS purges of files
    # untouched for ~3 days. The agent only runs at login/switch, so secrets
    # silently vanished and ~/.ssh/config became a dangling symlink.
    age.secretsDir = "/Users/${username}/.local/state/agenix";
    age.secretsMountPoint = "/Users/${username}/.local/state/agenix.d";

    age.secrets.ssh-config = {
      file = ../../secrets/ssh-config.age;
      path = "/Users/${username}/.ssh/config";
      mode = "0600";
    };

    # MCP auth tokens, exported as env vars by zsh (see home/modules/mcp.nix)
    age.secrets.mcp-env = {
      file = ../../secrets/mcp-env.age;
      path = "/Users/${username}/.config/mcp/secrets.env";
      mode = "0600";
    };

    # agenix includes `Crashed = false` in KeepAlive, which means "restart if not crashed"
    # (i.e. restart on every clean exit, including success). Override to only restart on failure.
    # @see https://github.com/ryantm/agenix/issues/372
    launchd.agents.activate-agenix.config.KeepAlive = lib.mkForce {
      SuccessfulExit = false;
    };
  };
}
