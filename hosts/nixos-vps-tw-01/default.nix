{ ... }:

{
  imports = [
    ../shared-nix-settings.nix
    ./hardware-configuration.nix
    ./hardware.nix
    ./networking.nix
    ./performance.nix
    ./users.nix
    ./services/snell-server.nix
  ];

  system.stateVersion = "25.05";
}
