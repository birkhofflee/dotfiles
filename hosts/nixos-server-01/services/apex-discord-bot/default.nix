{ config, inputs, ... }:
{
  # @see https://github.com/birkhofflee/apex-discord-bot?tab=readme-ov-file#environment-variables
  age.secrets.apex-discord-bot = {
    file = ../../../../secrets/apex-discord-bot.age;
  };

  systemd.services.apex-discord-bot = {
    description = "Apex Discord Bot";
    after = [
      "network.target"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      EnvironmentFile = config.age.secrets.apex-discord-bot.path;
      ExecStart = "${inputs.apex-discord-bot.packages.x86_64-linux.default}/bin/apex-discord-bot";
      Restart = "on-failure";
      DynamicUser = true;
    };
  };
}
