{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/proxmox-image.nix")

    ../shared-nix-settings.nix
    ../common-system-packages.nix

    ./hardware.nix
    ./networking.nix
    ./desktop.nix
    ./users.nix
    ./remote-builder.nix
    ./programs/1password.nix
  ];

  system.stateVersion = "25.05";
}
