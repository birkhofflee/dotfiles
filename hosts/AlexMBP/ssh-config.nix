{ config, currentSystemUser, ... }:
let
  username = currentSystemUser;
in
{
  age.identityPaths = [ "/Users/${username}/.ssh/id_ed25519" ];

  age.secrets.ssh-config = {
    file = ../../secrets/ssh-config.age;
    path = "/Users/${username}/.ssh/config";
    owner = username;
    mode = "600";
  };
}
