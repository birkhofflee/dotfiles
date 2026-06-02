{
  pkgs,
  lib,
  config,
  ...
}:
{
  # SSH agent socket — used by git, ssh, and other tools
  home.sessionVariables.SSH_AUTH_SOCK =
    if pkgs.stdenv.isDarwin then
      "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "${config.home.homeDirectory}/.1password/agent.sock";

  # Git commit signing via 1Password SSH agent
  programs.git.settings = {
    gpg = {
      format = "ssh";
      ssh.program =
        if pkgs.stdenv.isDarwin then
          "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else
          "/run/current-system/sw/bin/op-ssh-sign";
    };
    commit.gpgsign = lib.mkForce true;
  };

  # SSH agent
  # https://www.1password.dev/ssh/agent#configuration
  #
  # By default, the 1Password SSH agent will make every eligible key in the built-in Personal, Private, or Employee vault of your 1Password accounts available to offer to SSH servers. This configuration is automatically set up when you turn on the SSH agent.
  # If you need to use the SSH agent with keys saved in shared or custom vaults, you can create and customize an SSH agent config file (~/.config/1Password/ssh/agent.toml) to override the default agent configuration.

}
