{ pkgs, lib, config, ... }:
{
  # Linux: install 1Password packages (on macOS it's a Homebrew cask)
  home.packages = lib.mkIf pkgs.stdenv.isLinux [
    pkgs._1password-cli
    pkgs._1password-gui
  ];

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
          "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
    };
    commit.gpgsign = lib.mkForce true;
  };

  # SSH agent key configuration
  # https://developer.1password.com/docs/ssh/agent/config
  home.file.".config/1Password/ssh/agent.toml".text = ''
    # Managed by home-manager

    [[ssh-keys]]
    item = "2mjyhu76qqmeex23n35wzpj4ri"

    [[ssh-keys]]
    item = "xoa6h6kmwwlcznc26euhrqke3q"

    [[ssh-keys]]
    item = "lgpo25nfmotwf2inm67a7nboeu"

    [[ssh-keys]]
    item = "4rd5wm4adrtnmpnkxzi6baozh4"
  '';
}
