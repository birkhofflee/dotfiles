{ modulesPath, inputs, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/proxmox-image.nix")

    ../shared-nix-settings.nix
    ../common-system-packages.nix

    # For the GPU driver, we're using i915 SR-IOV (https://github.com/strongtz/i915-sriov-dkms).
    # This NixOS module adds pkgs.i915-sriov and pkgs.xe-sriov via a nixpkgs overlay via an overlay;
    # it is always imported so the overlay is available, but its packages are only used when enableHardwareAccel = true.
    #
    # Configuration:
    # - It needs to be installed on PVE host as well - see https://github.com/strongtz/i915-sriov-dkms/blob/master/docs/install-pve-host.md
    # - To pass a VF to this VM, in the PVE interface - Hardware - Add - PCI Device
    #   - Choose a VF in "Raw Device"
    #   - Tick "All Functions box"
    #   - Tick "Primary GPU"
    inputs.i915-sriov-dkms.nixosModules.default

    ./hardware.nix
    ./networking.nix
    ./desktop.nix
    ./users.nix
    ./programs/1password.nix
  ];

  system.stateVersion = "25.05";
}
