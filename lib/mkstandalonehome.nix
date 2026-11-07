# Standalone home-manager for non-NixOS Linux boxes (e.g. WSL), where mkSystem
# can't be used. Each one also runs a personal Rex server on its own tailnet node.
{
  nixpkgs,
  overlays,
  inputs,
}:

_name:
{
  system,
  user,
  extraModules ? [ ],
}:
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    inherit system overlays;
    config.allowUnfree = true;
  };
  extraSpecialArgs = {
    inherit inputs;
    currentSystemUser = user;
    hasDesktop = false;
  };
  modules = [
    ../home
    # mkSystem normally adds these at the system level
    inputs.nix-index-database.homeModules.nix-index
    inputs.rex.homeManagerModules.default
    {
      # Personal Rex server as a systemd user service (linger is on, so
      # it starts at boot), reachable over its own embedded tailnet node.
      # Also writes xterm-rex to ~/.terminfo, which the Nix-built zsh
      # needs: its ncurses doesn't search /usr/share/terminfo.
      services.rex = {
        enable = true;
        tailscale.enable = true;
        # systemd expands %H to the box's hostname when the service starts, so
        # the node follows it. Each name has its own saved identity: renaming
        # the box enrolls a new node that has to sign in again.
        tailscale.hostname = "%H";
      };
      # programs.ssh isn't managed here, and the distro's rex package
      # already installs the guard in /etc/ssh/ssh_config.d.
      programs.rex.sshGuard = false;

      # Rex sessions don't set SSH_*, so Starship would hide these as if
      # the shell were local. Always show which machine this is.
      programs.starship.settings = {
        username.show_always = true;
        hostname.ssh_only = false;
      };

      programs.nix-index-database.comma.enable = true;
      targets.genericLinux.enable = true;
      # ssh.nix publishes the 1Password key's pubkey; this box has its
      # own on-disk keypair, which that would leave mismatched.
      home.file.".ssh/id_ed25519.pub".enable = false;
      # Applied from a github: ref, so there's no ~/.config/dotfiles checkout
      # for the LazyVim out-of-store symlink to point at.
      dotfiles.neovim.mutableConfig = false;
    }
  ]
  ++ extraModules;
}
