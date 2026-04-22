{ pkgs, lib, currentSystemUser, ... }:

{
  # Default desktop: GNOME with GDM
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # HiDPI: set 2x scaling for the GDM login screen and GNOME session
  # @see https://discourse.nixos.org/t/need-help-for-nixos-gnome-scaling-settings/24590/12
  programs.dconf.profiles.gdm.databases = [{
    settings."org/gnome/desktop/interface".scaling-factor = lib.gvariant.mkUint32 2;
  }];

  # Using Gnome Remote Desktop for RDP
  services.gnome.gnome-remote-desktop.enable = true;

  systemd.services.gnome-remote-desktop = {
    wantedBy = [ "graphical.target" ];
  };

  # Provision a Tailscale TLS cert for GNOME Remote Desktop and configure the
  # system daemon. Runs on every boot.
  #
  # `tailscale cert` is idempotent and only fetches a new cert when the
  # existing one is near expiry.
  systemd.services.gnome-rdp-setup = {
    description = "Provision Tailscale TLS cert for GNOME Remote Desktop";
    after = [ "gnome-remote-desktop.service" "tailscaled.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath [ pkgs.tailscale pkgs.gnome-remote-desktop pkgs.jq pkgs.coreutils pkgs.systemd pkgs.openssl ]}";
      ExecStart = "${pkgs.writeShellScript "gnome-rdp-setup" ''
        set -euo pipefail

        # Wait for Tailscale to fully connect (first boot: auth key is consumed here)
        until tailscale status --json | jq -e '.BackendState == "Running"' > /dev/null 2>&1; do
          sleep 2
        done

        CERT_DIR=/var/lib/gnome-remote-desktop
        FQDN=$(tailscale status --json | jq -r '.Self.DNSName | rtrimstr(".")')

        # Try Tailscale-issued cert (Let's Encrypt); fall back to self-signed if rate-limited
        if timeout 60 tailscale cert \
            --cert-file $CERT_DIR/rdp.crt \
            --key-file  $CERT_DIR/rdp.key \
            "$FQDN" 2>/dev/null; then
          echo "Using Tailscale TLS certificate"
        else
          echo "tailscale cert failed or timed out, generating self-signed certificate"
          openssl req -x509 -newkey rsa:4096 -days 90 -nodes \
            -keyout $CERT_DIR/rdp.key \
            -out    $CERT_DIR/rdp.crt \
            -subj "/CN=$FQDN" \
            -addext "subjectAltName=DNS:$FQDN"
        fi
        chown gnome-remote-desktop $CERT_DIR/rdp.{crt,key}

        # Configuring headless multi user remote login
        # @see https://github.com/GNOME/gnome-remote-desktop/blob/master/README.md#headless-multi-user-remote-login
        grdctl --system rdp set-tls-cert $CERT_DIR/rdp.crt
        grdctl --system rdp set-tls-key  $CERT_DIR/rdp.key
        grdctl --system rdp set-credentials ${currentSystemUser} ${currentSystemUser}
        grdctl --system rdp disable-view-only
        grdctl --system rdp enable

        # Required for the RDP server to start listening
        systemctl restart gnome-remote-desktop.service
      ''}";
    };
  };

  services.displayManager.autoLogin = {
    enable = false;
  };

  # Disable systemd targets for sleep and hibernation
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Hyprland specialization — selectable from the GRUB boot menu.
  # specialisation.hyprland.configuration = {
  #   services.displayManager.gdm.enable = lib.mkForce false;
  #   services.desktopManager.gnome.enable = lib.mkForce false;
  #   programs.hyprland.enable = true;
  #   services.displayManager.sddm.enable = true;
  #   services.displayManager.sddm.wayland.enable = true;

  #   # Autologin so wayvnc has a running Wayland session to connect to.
  #   services.displayManager.autoLogin.enable = true;
  #   services.displayManager.autoLogin.user = username;

  #   # wayvnc: VNC server for wlroots-based Wayland compositors (Hyprland).
  #   # xrdp cannot create Wayland sessions; wayvnc attaches to the running compositor.
  #   # Client: TigerVNC viewer connecting to port 5900.
  #   systemd.user.services.wayvnc = {
  #     description = "wayvnc VNC server";
  #     after = [ "graphical-session.target" ];
  #     wantedBy = [ "graphical-session.target" ];
  #     serviceConfig = {
  #       ExecStart = "${pkgs.wayvnc}/bin/wayvnc 0.0.0.0 5900";
  #       Restart = "on-failure";
  #       RestartSec = 3;
  #     };
  #   };

  #   networking.firewall.allowedTCPPorts = [ 5900 ]; # merged with base [ 22 ]
  # };
}
