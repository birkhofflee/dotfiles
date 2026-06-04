{ currentSystemName, ... }:

{
  networking = {
    computerName = "${currentSystemName}";
    hostName = "${currentSystemName}";

    applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      # allowSigned = true; # Whether to enable built-in software to receive incoming connections.
      # allowSignedApp = true; # Whether to enable downloaded signed software to receive incoming connections.
      # blockAllIncoming = true; # Whether to enable blocking all incoming connections.
    };
  };
  system.defaults.smb.NetBIOSName = "${currentSystemName}";

  # Enable sudo authentication with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  # Enable pam_reattach to allow sudo to be used with Touch ID
  security.pam.services.sudo_local.reattach = true;
}
