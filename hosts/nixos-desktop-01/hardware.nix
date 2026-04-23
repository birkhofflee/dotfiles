{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nixos-desktop-01;
in
{
  options.nixos-desktop-01.enableHardwareAccel = lib.mkOption {
    type = lib.types.bool;
    default = false; # blocked by https://github.com/strongtz/i915-sriov-dkms/issues/302#issuecomment-4292644321
    description = "Enable Intel SR-IOV GPU passthrough and hardware acceleration.";
  };

  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    hardware.graphics = lib.mkIf cfg.enableHardwareAccel {
      enable = true;
      extraPackages = [ pkgs.intel-media-driver ]; # non-free iHD VA-API driver for Intel Gen 8+
    };

    # Disable cloud-init: everything (hostname, users, SSH keys) is declared in Nix,
    # so cloud-init only gets in the way, e.g. it forces networking.hostName = "" by default.
    proxmox.cloudInit.enable = false;

    # OVMF (UEFI) boot: use systemd-boot. It auto-discovers all NixOS generations
    # and specialisations as separate entries, no manual GRUB entry management needed.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = lib.mkForce 3;
    boot.extraModulePackages = lib.mkIf cfg.enableHardwareAccel [ pkgs.i915-sriov ];

    proxmox.qemuConf = {
      name = "nixos-desktop-01";
      bios = "ovmf";
      cores = 4;
      memory = 8192;
      net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=1"; # overridden using qmrestore --unique
    };

    proxmox.qemuExtraConf = {
      cpu = "host";
      numa = 0;
      onboot = 1;
      rng0 = "source=/dev/urandom";
    }
    // lib.optionalAttrs cfg.enableHardwareAccel {
      # For the VF device (virtualised GPU)
      hostpci0 = "0000:00:02.1,x-vga=1";
    };

    # For a small server, disk swap is fine but slow; zram creates a compressed
    # swap space in RAM, trading a little CPU for much faster "swap." It reduces SSD
    # wear and usually keeps the system responsive under memory pressure.
    zramSwap = {
      enable = true;
      memoryPercent = 75;
      algorithm = "zstd";
    };

    # Periodic TRIM for thin-provisioned PVE storage
    services.fstrim.enable = true;
  };
}
