{ pkgs, lib, inputs, currentSystemUser, ... }:
let
  username = currentSystemUser;
in
{
  home-manager.sharedModules = [ inputs.agenix.homeManagerModules.age ];

  home-manager.users.${username} = {
    age.package = pkgs.age-with-plugins;
    age.identityPaths = [ "${./age-identity.txt}" ];

    age.secrets.ssh-config = {
      file = ../../secrets/ssh-config.age;
      path = "/Users/${username}/.ssh/config";
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
