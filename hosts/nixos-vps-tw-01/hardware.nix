{ lib, ... }:

{
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # EFI boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkForce 3;

  services.qemuGuest.enable = true;

  # For a small VPS, zram creates a compressed swap space in RAM, trading a
  # little CPU for much faster "swap" and less SSD wear under memory pressure.
  zramSwap = {
    enable = true;
    memoryPercent = 75;
    algorithm = "zstd";
  };

  services.fstrim.enable = true;
}
